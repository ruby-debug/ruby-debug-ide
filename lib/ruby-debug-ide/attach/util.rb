require 'ruby-debug-ide/attach/lldb'
require 'ruby-debug-ide/attach/gdb'
require 'socket'
require 'set'

def attach_and_return_thread(options, pid, debugger_loader_path, argv)
  Thread.new(argv) do |argv|

    debugger = choose_debugger(options.ruby_path, pid, options.gems_to_include, debugger_loader_path, argv)

    trap('INT') do
      unless debugger.exited?
        $stderr.puts "backtraces for threads:\n\n"
        process_threads = debugger.process_threads
        if process_threads
          process_threads.each do |thread|
            $stderr.puts "#{thread.thread_info}\n#{thread.last_bt}\n\n"
          end
        end
        debugger.exit
      end
      exit!
    end

    debugger.attach_to_process
    debugger.set_flags

    if debugger.check_already_under_debug
      $stderr.puts "Process #{debugger.pid} is already under debug"
      debugger.exit
      exit!
    end

    should_check_threads_state = true

    while should_check_threads_state
      should_check_threads_state = false
      debugger.update_threads.each do |thread|
        thread.switch
        while thread.need_finish_frame
          should_check_threads_state = true
          thread.finish
        end
      end
    end

    debugger.wait_line_event
    debugger.load_debugger
    debugger.exit
  end
end

def get_child_pids(pid)
  return [] unless command_exists 'pgrep'

  pids = Array.new

  q = Queue.new
  q.push(pid)

  until q.empty? do
    pid = q.pop

    pipe = IO.popen("pgrep -P #{pid}")

    pipe.readlines.each do |child|
      child_pid = child.strip.to_i
      q.push(child_pid)
      pids << child_pid
    end
  end

  filter_ruby_processes(pids)
end

def filter_ruby_processes(pids)
  pipe = IO.popen(%Q(lsof -c ruby | awk '{print $2 ":" $9}' | grep -E 'bin/ruby([[:digit:]]+\.?)*$'))

  ruby_processes = Set.new

  pipe.readlines.each do |process|
    pid = process.split(/:/).first
    ruby_processes.add(pid.to_i)
  end

  ruby_processes_pids, non_ruby_processes_pids = pids.partition {|pid| ruby_processes.include? pid}

  DebugPrinter.print_debug("The following child processes was added to attach: #{ruby_processes_pids.join(', ')}") unless ruby_processes_pids.empty?
  DebugPrinter.print_debug("The following child are not ruby processes: #{non_ruby_processes_pids.join(', ')}") unless non_ruby_processes_pids.empty?

  ruby_processes_pids
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

def choose_debugger(ruby_path, pid, gems_to_include, debugger_loader_path, argv)
  if command_exists(LLDB.to_s)
    debugger = LLDB.new(ruby_path, pid, '--no-lldbinit', gems_to_include, debugger_loader_path, argv)
  elsif command_exists(GDB.to_s)
    debugger = GDB.new(ruby_path, pid, '-nh -nx', gems_to_include, debugger_loader_path, argv)
  else
    raise 'Neither gdb nor lldb was found. Aborting.'
  end

  debugger
end