require 'ruby-debug-ide/interface'
require 'ruby-debug-ide/command'

module Debugger
  class IdeCommandProcessor
    def initialize(interface = nil)
      @interface = interface
      @printer = XmlPrinter.new(@interface)
    end

    def print(*args)
      @interface.print(*args)
    end

    def process_commands
      unless Debugger.event_processor.at_line?
        @printer.print_error "There is no thread suspended at the time and therefore no context to execute '#{input.gsub('%', '%%')}'"
        return
      end
      context = Debugger.event_processor.context
      file = Debugger.event_processor.file
      line = Debugger.event_processor.line
      state = State.new do |s|
        s.context = context
        s.file    = file
        s.line    = line
        s.binding = context.frame_binding(0)
        s.interface = @interface
      end
      event_cmds = Command.commands.map{|cmd| cmd.new(state, @printer) }
      while !state.proceed? do
        input = @interface.command_queue.empty? ? nil : @interface.command_queue.shift
        unless input
          sleep 0.1
          next
        end
        catch(:debug_error) do
          splitter[input].each do |input|
            # escape % since print_debug might use printf
            @printer.print_debug "Processing in context: #{input.gsub('%', '%%')}"
            if cmd = event_cmds.find { |c| c.match(input) }
              if context.dead? && cmd.class.need_context
                @printer.print_msg "Command is unavailable\n"
              else
                cmd.execute
              end
            else
              @printer.print_msg "Unknown command: #{input}"
            end
          end
        end
      end
    rescue IOError, Errno::EPIPE
      @printer.print_error "INTERNAL ERROR!!! #{$!}\n" rescue nil
      @printer.print_error $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
    rescue Exception
      @printer.print_error "INTERNAL ERROR!!! #{$!}\n" rescue nil
      @printer.print_error $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
    end

    def splitter
      lambda do |str|
        str.split(/;/).inject([]) do |m, v|
          if m.empty?
            m << v
          else
            if m.last[-1] == ?\\
              m.last[-1,1] = ''
              m.last << ';' << v
            else
              m << v
            end
          end
          m
        end
      end
    end    
  end
    
  class IdeControlCommandProcessor < IdeCommandProcessor# :nodoc:
    def process_commands
      @printer.print_debug("Starting control thread")
      ctrl_cmd_classes = Command.commands.select{|cmd| cmd.control}
      state = ControlState.new(@interface)
      ctrl_cmds = ctrl_cmd_classes.map{|cmd| cmd.new(state, @printer)}
      
      while input = @interface.read_command
        # escape % since print_debug might use printf
        # sleep 0.3
        catch(:debug_error) do
          if cmd = ctrl_cmds.find{|c| c.match(input) }
            @printer.print_debug "Processing in control: #{input.gsub('%', '%%')}"
            cmd.execute
          else
            @interface.command_queue << input
          end
        end
      end
    rescue IOError, Errno::EPIPE
      @printer.print_error "INTERNAL ERROR!!! #{$!}\n" rescue nil
      @printer.print_error $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
    rescue Exception
      @printer.print_error "INTERNAL ERROR!!! #{$!}\n" rescue nil
      @printer.print_error $!.backtrace.map{|l| "\t#{l}"}.join("\n") rescue nil
    ensure
      @interface.close
    end
  end

  class State # :nodoc:

    attr_accessor :context, :file, :line, :binding
    attr_accessor :frame_pos, :previous_line
    attr_accessor :interface
    
    def initialize
      @frame_pos = 0
      @previous_line = nil
      @proceed = false
      yield self
    end
    
    def print(*args)
      @interface.print(*args)
    end
    
    def proceed?
      @proceed
    end
    
    def proceed
      @proceed = true
    end
  end
  
  class ControlState # :nodoc:

    def initialize(interface)
      @interface = interface
    end
    
    def proceed
    end
    
    def print(*args)
      @interface.print(*args)
    end
    
    def context
      nil
    end
    
    def file
      print "ERROR: No filename given.\n"
      throw :debug_error
    end
  end
end
