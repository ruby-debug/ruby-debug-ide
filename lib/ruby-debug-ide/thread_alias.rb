module Debugger
  module TimeoutHandler
    class << self
      def do_thread_alias
        if defined? ::OldThread
          Debugger.print_debug 'Tried to re-alias thread for eval'
          return
        end

        Object.const_set :OldThread, ::Thread
        Object.send :remove_const, :Thread
        Object.const_set :Thread, ::Debugger::DebugThread
      end

      def undo_thread_alias
        unless defined? ::OldThread
          Debugger.print_debug 'Tried to de-alias thread twice'
          return
        end

        Object.send :remove_const, :Thread
        Object.const_set :Thread, ::OldThread
        Object.send :remove_const, :OldThread
      end
    end
  end
end