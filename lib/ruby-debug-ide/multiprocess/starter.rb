if ENV['IDE_PROCESS_DISPATCHER']
  require 'rubygems'
  $: << File.expand_path(File.dirname(__FILE__)) + "../.."
  require 'ruby-debug-ide'
  require 'ruby-debug-ide/multiprocess'
  Debugger::MultiProcess::pre_child
end