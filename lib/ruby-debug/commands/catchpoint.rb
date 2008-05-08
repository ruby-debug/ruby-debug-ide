module Debugger
  class CatchCommand < Command # :nodoc:
    self.control = true

    def regexp
      /^\s*cat(?:ch)?(?:\s+(.+))?$/
    end

    def execute
      if excn = @match[1]
        if excn == 'off'
          Debugger.catchpoint = nil
          print_msg "Clear catchpoint."
        else
          Debugger.catchpoint = excn
          print_msg "Set catchpoint %s.", excn
        end
      else
        if Debugger.catchpoint
          print_msg "Catchpoint %s.", Debugger.catchpoint
        else
          print_msg "No catchpoint."
        end
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