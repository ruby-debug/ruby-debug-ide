module Debugger
  module TimeoutHandler
    class << self
      def do_thread_alias
        load File.expand_path(File.dirname(__FILE__) + '/thread-alias/alias_thread.rb')
      end

      def undo_thread_alias
        load File.expand_path(File.dirname(__FILE__) + '/thread-alias/unalias_thread.rb')
      end
    end
  end
end