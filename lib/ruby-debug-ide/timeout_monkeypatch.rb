module Debugger
  module TimeoutHandler
    class << self
      def do_timeout_monkey
        load File.expand_path(File.dirname(__FILE__) + '/timeout-patch/monkey_timeout.rb')
      end

      def undo_timeout_monkey
        load File.expand_path(File.dirname(__FILE__) + '/timeout-patch/unmonkey_timeout.rb')
      end
    end
  end
end