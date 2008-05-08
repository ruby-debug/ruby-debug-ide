 require 'ruby-debug/xml_printer'
 module Debugger
   
   class EventProcessor
   
     attr_accessor :line, :file, :context
    
     def initialize(interface)
       @printer = XmlPrinter.new(interface)
       @line = nil
       @file = nil
     end
    
     def at_breakpoint(context, breakpoint)
       n = Debugger.breakpoints.index(breakpoint) + 1
       @printer.print_breakpoint n, breakpoint
     end
     
     def at_catchpoint(context, excpt)
       @printer.print_catchpoint(excpt)
     end
     
     def at_tracing(context, file, line)
       @printer.print_trace(context, file, line)
     end
     
     def at_line(context, file, line)
       @printer.print_at_line(file, line) if context.nil? || context.stop_reason == :step
       @line=line
       @file =file
       @context = context
       @printer.print_debug("Stopping Thread %s", context.thread.to_s)
       @printer.print_debug("Threads equal: %s", Thread.current == context.thread)
       Thread.stop
       @printer.print_debug("Resumed Thread %s", context.thread.to_s)
       @line=nil
       @file = nil
       @context = nil
     end

     def at_line?
        @line
     end     
   end
 end