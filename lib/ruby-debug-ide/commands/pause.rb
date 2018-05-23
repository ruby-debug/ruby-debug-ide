module Debugger

  # Implements debugger "pause" command
  class PauseCommand < Command
    self.control = true

    def regexp
      /^\s*pause\s*(?:\s+(\S+))?\s*$/
    end

    def execute

      #only for debase versions > 0.2.3.beta1
      if Debugger.respond_to?(:thread_context)
        Thread.list.each do |th|
          Debugger.thread_context th unless th.is_a? DebugThread
        end
      end

      Debugger.contexts.each do |c|
        unless c.respond_to?(:pause)
          print_msg "Not implemented"
          return
        end
        c.pause
      end
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
