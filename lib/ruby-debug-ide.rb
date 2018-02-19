require 'pp'
require 'stringio'
require "socket"
require 'thread'
if RUBY_VERSION < '2.0' || defined?(JRUBY_VERSION)
  require 'ruby-debug-base'
  Debugger::FRONT_END = "ruby-debug-base"
else
  require 'debase'
  Debugger::FRONT_END = "debase"
end

require 'ruby-debug-ide/greeter'
require 'ruby-debug-ide/xml_printer'
require 'ruby-debug-ide/ide_processor'
require 'ruby-debug-ide/event_processor'

module Debugger

  class << self
    def find_free_port(host)
      server = TCPServer.open(host, 0)
      port   = server.addr[1]
      server.close
      port
    end

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

    attr_accessor :attached
    attr_accessor :cli_debug, :xml_debug, :evaluation_timeout
    attr_accessor :trace_to_s, :debugger_memory_limit, :inspect_time_limit
    attr_accessor :control_thread
    attr_reader :interface
    # protocol extensions
    attr_accessor :catchpoint_deleted_event, :value_as_nested_element


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

    def start_server(host = nil, port = 1234, notify_dispatcher = false)
      return if started?
      start
      start_control(host, port, notify_dispatcher)
    end

    def prepare_debugger(options)
      @mutex = Mutex.new
      @proceed = ConditionVariable.new

      start_server(options.host, options.port, options.notify_dispatcher)

      raise "Control thread did not start (#{@control_thread}}" unless @control_thread && @control_thread.alive?

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

    def start_control(host, port, notify_dispatcher)
      raise "Debugger is not started" unless started?
      return if @control_thread
      @control_thread = DebugThread.new do
        begin
          # 127.0.0.1 seemingly works with all systems and with IPv6 as well.
          # "localhost" and nil have problems on some systems.
          host ||= '127.0.0.1'

          server = notify_dispatcher_if_needed(host, port, notify_dispatcher) do |real_port, port_changed = false|
            server = TCPServer.new(host, real_port)
            print_greeting_msg $stderr, host, real_port, port_changed ? "Subprocess" : "Fast" if defined? IDE_VERSION
            server
          end

          return unless server

          while (session = server.accept)
            $stderr.puts "Connected from #{session.peeraddr[2]}" if Debugger.cli_debug
            dispatcher = ENV['IDE_PROCESS_DISPATCHER']
            if dispatcher
              ENV['IDE_PROCESS_DISPATCHER'] = "#{session.peeraddr[2]}:#{dispatcher}" unless dispatcher.include?(":")
              ENV['DEBUGGER_HOST'] = host
            end
            begin
              @interface = RemoteInterface.new(session)
              self.handler = EventProcessor.new(interface)
              IdeControlCommandProcessor.new(interface).process_commands
            rescue StandardError, ScriptError => ex
              bt = ex.backtrace
              $stderr.printf "#{Process.pid}: Exception in DebugThread loop: #{ex.message}(#{ex.class})\nBacktrace:\n#{bt ? bt.join("\n  from: ") : "<none>"}\n"
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

    private

    def notify_dispatcher_if_needed(host, port, need_notify)
      return yield port unless need_notify

      return unless ENV['IDE_PROCESS_DISPATCHER']
      acceptor_host, acceptor_port = ENV['IDE_PROCESS_DISPATCHER'].split(":")
      acceptor_host, acceptor_port = '127.0.0.1', acceptor_host unless acceptor_port
      connected = false

      3.times do |i|
        begin
          s = TCPSocket.open(acceptor_host, acceptor_port)
          dispatcher_answer = s.gets.chomp

          if dispatcher_answer == "true"
            port = Debugger.find_free_port(host)
          end

          server = yield port, dispatcher_answer == "true"

          s.print(port)
          s.close
          connected = true
          print_debug "Ide process dispatcher notified about sub-debugger which listens on #{port}\n"
          return server
        rescue => bt
          $stderr.puts "#{Process.pid}: connection failed(#{i+1})"
          $stderr.puts "Exception: #{bt}"
          $stderr.puts bt.backtrace.map { |l| "\t#{l}" }.join("\n")
          sleep 0.3
        end unless connected
      end
    end
  end

  class Exception # :nodoc:
    attr_reader :__debug_file, :__debug_line, :__debug_binding, :__debug_context
  end
end
