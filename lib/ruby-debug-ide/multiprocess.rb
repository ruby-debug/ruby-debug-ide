if RUBY_VERSION < '1.9'
  require 'ruby-debug-ide/multiprocess/pre_child'
else
  require_relative 'multiprocess/pre_child'
end

module Debugger
  module MultiProcess
    class << self
      def do_monkey
        load File.expand_path(File.dirname(__FILE__) + '/multiprocess/monkey.rb')
      end

      def undo_monkey
        if ENV['IDE_PROCESS_DISPATCHER']
          load File.expand_path(File.dirname(__FILE__) + '/multiprocess/unmonkey.rb')
          ruby_opts = ENV['RUBYOPT'].split(' ')
          ENV['RUBYOPT'] = ruby_opts.keep_if {|opt| !opt.end_with?('ruby-debug-ide/multiprocess/starter')}.join(' ')
        end
      end
    end
  end
end