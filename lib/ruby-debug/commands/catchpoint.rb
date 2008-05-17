module Debugger
  class CatchCommand < Command # :nodoc:
    self.control = true

    def regexp
      /^\s* cat(?:ch)? (?:\s+(.+))? $/x
    end

    def execute
      excn = @match[1]
      unless excn
        errmsg "Exception class must be specified for 'catch' command"
      else
        binding = @state.context ? get_binding : TOPLEVEL_BINDING
        unless debug_eval("#{excn}.is_a?(Class)", binding)
          print_msg "Warning #{excn} is not known to be a Class"
        end
        Debugger.add_catchpoint(excn)
        print_msg "Set catchpoint %s.", excn
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
