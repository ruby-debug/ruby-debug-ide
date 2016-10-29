require 'ruby-debug-ide/attach/native_debugger'

class GDB < NativeDebugger

  def initialize(executable, pid, flags, gems_to_include, debugger_loader_path, argv)
    super(executable, pid, flags, gems_to_include, debugger_loader_path, argv)
  end

  def set_flags
    execute 'set scheduler-locking off' # we will deadlock with it
    execute 'set unwindonsignal on'     # in case of some signal we will exit gdb
  end

  def update_threads
    @process_threads = []
    info_threads = (execute 'info threads').split("\n")
    info_threads.each do |thread_info|
      next unless thread_info =~ /[\s*]*\d+\s+Thread.*/
      $stdout.puts "thread_info: #{thread_info}"
      is_main = thread_info[0] == '*'
      thread_num = thread_info.sub(/[\s*]*/, '').sub(/\s.*$/, '').to_i
      thread = ProcessThread.new(thread_num, is_main, thread_info, self)
      if thread.is_main
        @main_thread = thread
      end
      @process_threads << thread
    end
    @process_threads
  end

  def check_already_under_debug
    threads = execute 'info threads'
    threads =~ /ruby-debug-ide/
  end

  def switch_to_thread(thread_num)
    execute "thread #{thread_num}"
  end

  def set_break(str)
    execute "tbreak #{str}"
  end

  def call_start_attach
    super()
    execute "call dlopen(\"#{@path_to_attach}\", 2)"
    execute 'call debase_start_attach()'
    set_break(@tbreak)
  end

  def print_delimiter
    @pipe.puts "print \"#{@delimiter}\""
  end

  def check_delimiter(line)
    line =~ /\$\d+\s=\s"#{@delimiter}"/
  end

  def load_debugger
    execute "call #{@eval_string}"
  end

  def to_s
    GDB.to_s
  end

  class << self
    def to_s
      'gdb'
    end
  end

end
