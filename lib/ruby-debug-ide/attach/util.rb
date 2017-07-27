require 'ruby-debug-ide/attach/lldb'
require 'ruby-debug-ide/attach/gdb'
require 'socket'

def get_child_pids(pid, pids = Array.new)
  pids << pid
  pipe = IO.popen("pgrep -P #{pid}")

  pipe.readlines.each do |child_pid|
    pids = get_child_pids(child_pid.to_i, pids)
  end
  pids
end

def command_exists(command)
  checking_command = "checking command #{command} for existence\n"
  `command -v #{command} >/dev/null 2>&1 || { exit 1; }`
  if $?.exitstatus != 0
    DebugPrinter.print_debug("#{checking_command}command does not exist.")
  else
    DebugPrinter.print_debug("#{checking_command}command does exist.")
  end
  $?.exitstatus == 0
end

def choose_debugger(ruby_path, gems_to_include, debugger_loader_path, argv)
  if command_exists(LLDB.to_s)
    debugger = LLDB.new(ruby_path, '--no-lldbinit', gems_to_include, debugger_loader_path, argv)
  elsif command_exists(GDB.to_s)
    debugger = GDB.new(ruby_path, '-nh -nx', gems_to_include, debugger_loader_path, argv)
  else
    raise 'Neither gdb nor lldb was found. Aborting.'
  end

  debugger
end
