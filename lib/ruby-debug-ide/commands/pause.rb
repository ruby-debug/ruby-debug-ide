module Debugger

  # Implements debugger "pause" command
  class PauseCommand < Command
    self.control = true

    def regexp
      /^\s*pause\s*(?:\s+(\S+))?\s*$/
    end

    def execute
      c = get_context(@match[1].to_i)
      unless c.respond_to?(:pause)
        print_msg "Not implemented"
        return
      end
      c.pause
    end

    class << self
      def help_command
        %w[pause]
      end

      def help(cmd)
        %{
          pause <nnn>\tpause a running thread
         }
     end
    end
  end
end
