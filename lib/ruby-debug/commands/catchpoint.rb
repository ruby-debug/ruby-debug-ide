module Debugger
  class CatchCommand < Command # :nodoc:
    self.control = true

    def regexp
      /^\s* cat(?:ch)? (?:\s+(.+))? $/x
    end

    def execute
      exception_class_name = @match[1]
      unless exception_class_name
        errmsg "Exception class must be specified for 'catch' command"
      else
        binding = @state.context ? get_binding : TOPLEVEL_BINDING
        unless debug_eval("#{exception_class_name}.is_a?(Class)", binding)
          print_msg "Warning #{exception_class_name} is not known to be a Class"
        end
        Debugger.add_catchpoint(exception_class_name)
        print_catchpoint_set(exception_class_name)
      end
    end
    
    class << self
      def help_command
        'catch'
      end

      def help(cmd)
        %{
          cat[ch]\t\t\tshow catchpoint
          cat[ch] <an Exception>\tset catchpoint to an exception
        }
      end
    end
  end
end
