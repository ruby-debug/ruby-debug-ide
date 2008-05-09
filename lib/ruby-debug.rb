require 'pp'
require 'stringio'
require "socket"
require 'thread'
require 'ruby-debug-base'
require 'ruby-debug/xml_printer'
require 'ruby-debug/processor'
require 'ruby-debug/event_processor'

module Debugger
  
  class << self
    # Prints to the stderr using printf(*args) if debug logging flag (-d) is on.
    def print_debug(*args)
      if Debugger.is_debug
        $stderr.printf(*args)
        $stderr.printf("\n")
        $stderr.flush
      end
    end
  end
  
  class Context
    def interrupt
      self.stop_next = 1
    end
    
    private
    
    def event_processor
      Debugger.event_processor
    end
    
    def at_breakpoint(breakpoint)
      event_processor.at_breakpoint(self, breakpoint)
    end
    
    def at_catchpoint(excpt)
      event_processor.at_catchpoint(self, excpt)
    end
    
    def at_tracing(file, line)
      event_processor.at_tracing(self, file, line)
    end
    
    def at_line(file, line)
      event_processor.at_line(self, file, line)
    end
 
    def at_return(file, line)
      event_processor.at_return(self, file, line)
    end
  end
  
  class << self
    attr_accessor :event_processor, :is_debug
    attr_reader :control_thread
    
    #
    # Interrupts the current thread
    #
    def interrupt
      current_context.interrupt
    end
    
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
    
    def main(host, port)
      return if started?
      
      start
      
      start_control(host, port)
      
      @mutex = Mutex.new
      @proceed = ConditionVariable.new
      
      # wait for start command
      @mutex.synchronize do
        @proceed.wait(@mutex)
      end 
      
      debug_load Debugger::PROG_SCRIPT
    end
    
    def run_prog_script
      @mutex.synchronize do
        @proceed.signal
      end
    end
    
    def start_control(host, port)
      raise "Debugger is not started" unless started?
      return if @control_thread
      @control_thread = DebugThread.new do
        host ||= 'localhost' # nil does not seem to work for IPv6, localhost does
        Debugger.print_debug("Waiting for connection on '#{host}:#{port}'")
        server = TCPServer.new(host, port)
        while (session = server.accept)
          begin
            interface = RemoteInterface.new(session)
            @event_processor = EventProcessor.new(interface)
            ControlCommandProcessor.new(interface).process_commands
          rescue StandardError, ScriptError => ex
            puts ex
          end
        end
      end
    end
    
  end
  
  class Exception # :nodoc:
    attr_reader :__debug_file, :__debug_line, :__debug_binding, :__debug_context
  end
  
  module Kernel
    #
    # Stops the current thread after a number of _steps_ made.
    #
    def debugger(steps = 1)
      Debugger.current_context.stop_next = steps
    end
    
    #
    # Returns a binding of n-th call frame
    #
    def binding_n(n = 0)
      Debugger.current_context.frame_binding[n+1]
    end
  end
  
end
