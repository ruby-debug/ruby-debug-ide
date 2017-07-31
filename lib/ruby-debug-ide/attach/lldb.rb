require 'ruby-debug-ide/attach/native_debugger'

class LLDB < NativeDebugger

  def initialize(executable, pid, flags, gems_to_include, debugger_loader_path, argv)
    super(executable, pid, flags, gems_to_include, debugger_loader_path, argv)
  end

  def set_flags

  end

  def update_threads
    @process_threads = []
    info_threads = (execute 'thread list').split("\n")
    info_threads.each do |thread_info|
      next unless thread_info =~ /[\s*]*thread\s#\d+.*/
      is_main = thread_info[0] == '*'
      thread_num = thread_info.sub(/[\s*]*thread\s#/, '').sub(/:\s.*$/, '').to_i
      thread = ProcessThread.new(thread_num, is_main, thread_info, self)
      if thread.is_main
        @main_thread = thread
      end
      @process_threads << thread
    end
    @process_threads
  end

  def check_already_under_debug
    threads = execute 'thread list'
    threads =~ /ruby-debug-ide/
  end

  def switch_to_thread(thread_num)
    execute "thread select #{thread_num}"
  end

  def set_break(str)
    execute "breakpoint set --shlib #{@path_to_attach} --name #{str}"
  end

  def call_start_attach
    super()
    execute "expr (void *) dlopen(\"#{@path_to_attach}\", 2)"
    execute 'expr (int) debase_start_attach()'
    set_break(@tbreak)
  end

  def print_delimiter
    @pipe.puts "script print \"#{@delimiter}\""
  end

  def check_delimiter(line)
    line =~ /#{@delimiter}$/
  end

  def load_debugger
    execute "expr (void) #{@eval_string}"
  end

  def to_s
    LLDB.to_s
  end

  class << self
    def to_s
      'lldb'
    end
  end

end
