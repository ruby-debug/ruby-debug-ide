require 'pp'
require 'stringio'
require "socket"
require 'thread'
if (RUBY_VERSION < '2.0' || defined?(JRUBY_VERSION))
  require 'ruby-debug-base'
else
  require 'debase'
end

require 'ruby-debug-ide/version'
require 'ruby-debug-ide/xml_printer'
require 'ruby-debug-ide/ide_processor'
require 'ruby-debug-ide/event_processor'

module Debugger

  class << self
    # Prints to the stderr using printf(*args) if debug logging flag (-d) is on.
    def print_debug(*args)
      if Debugger.cli_debug
        $stderr.printf("#{Process.pid}: ")
        $stderr.printf(*args)
        $stderr.printf("\n")
        $stderr.flush
      end
    end

    def cleanup_backtrace(backtrace)
       cleared = []
       return cleared unless backtrace
       backtrace.each do |line|
         if line.index(File.expand_path(File.dirname(__FILE__) + "/..")) == 0
           next
         end
         if line.index("-e:1") == 0
           break
         end
         cleared << line
       end
       cleared
    end

    attr_accessor :cli_debug, :xml_debug
    attr_accessor :control_thread
    attr_reader :interface


    #
    # Interrupts the last debugged thread
    #
    def interrupt_last
      skip do
        if context = last_context
          return nil unless context.thread.alive?
          context.interrupt
        end
        context
      end
    end

    def start_server(host = nil, port = 1234)
      return if started?
      start
      start_control(host, port)
    end

    def prepare_debugger(options)
      start_server(options.host, options.port)

      raise "Control thread did not start (#{@control_thread}}" unless @control_thread && @control_thread.alive?

      @mutex = Mutex.new
      @proceed = ConditionVariable.new

      # wait for 'start' command
      @mutex.synchronize do
        @proceed.wait(@mutex)
      end
    end

    def debug_program(options)
      prepare_debugger(options)

      abs_prog_script = File.expand_path(Debugger::PROG_SCRIPT)
      bt = debug_load(abs_prog_script, options.stop, options.load_mode)
      if bt && !bt.is_a?(SystemExit)
        $stderr.print "Uncaught exception: #{bt}\n"
        $stderr.print Debugger.cleanup_backtrace(bt.backtrace).map{|l| "\t#{l}"}.join("\n"), "\n"
      end
    end

    def run_prog_script
      return unless @mutex
      @mutex.synchronize do
        @proceed.signal
      end
    end

    def start_control(host, port)
      raise "Debugger is not started" unless started?
      return if @control_thread
      @control_thread = DebugThread.new do
        begin
          # 127.0.0.1 seemingly works with all systems and with IPv6 as well.
          # "localhost" and nil have problems on some systems.
          host ||= '127.0.0.1'
          gem_name = (defined?(JRUBY_VERSION) || RUBY_VERSION < '1.9.0') ? 'ruby-debug-base' :
                     RUBY_VERSION < '2.0.0' ? 'ruby-debug-base19x' : 'debase'
          $stderr.printf "Fast Debugger (ruby-debug-ide #{IDE_VERSION}, #{gem_name} #{VERSION}) listens on #{host}:#{port}\n"
          server = TCPServer.new(host, port)
          while (session = server.accept)
            $stderr.puts "Connected from #{session.peeraddr[2]}" if Debugger.cli_debug
            dispatcher = ENV['IDE_PROCESS_DISPATCHER']
            if (dispatcher)
              ENV['IDE_PROCESS_DISPATCHER'] = "#{session.peeraddr[2]}:#{dispatcher}" unless dispatcher.include?(":")
              ENV['DEBUGGER_HOST'] = host
            end
            begin
              @interface = RemoteInterface.new(session)
              self.handler = EventProcessor.new(interface)
              IdeControlCommandProcessor.new(interface).process_commands
            rescue StandardError, ScriptError => ex
              bt = ex.backtrace
              $stderr.printf "#{Process.pid}: Exception in DebugThread loop: #{ex.message}\nBacktrace:\n#{bt ? bt.join("\n  from: ") : "<none>"}\n"
              exit 1
            end
          end
        rescue
          bt = $!.backtrace
          $stderr.printf "Fatal exception in DebugThread loop: #{$!.message}\nBacktrace:\n#{bt ? bt.join("\n  from: ") : "<none>"}\n"
          exit 2
        end
      end
    end

  end

  class Exception # :nodoc:
    attr_reader :__debug_file, :__debug_line, :__debug_binding, :__debug_context
  end
end
