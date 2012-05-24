if ENV['IDE_PROCESS_DISPATCHER']
  require 'rubygems'
  require 'ruby-debug-ide'
  require 'ruby-debug-ide/multiprocess'
  Debugger::MultiProcess::pre_child
end