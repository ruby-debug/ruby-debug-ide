require 'ruby-debug-ide/attach/native_debugger'

class ProcessThread

  attr_reader :thread_num, :is_main, :thread_info, :last_bt

  def initialize(thread_num, is_main, thread_info, native_debugger)
    @thread_num = thread_num
    @is_main = is_main
    @native_debugger = native_debugger
    @thread_info = thread_info
    @last_bt = nil
  end

  def switch
    @native_debugger.switch_to_thread(thread_num)
  end

  def finish
    @native_debugger.execute 'finish'
  end

  def get_bt
    @last_bt = @native_debugger.execute 'bt'
  end

  def any_caller_match(bt, pattern)
    bt =~ /#{pattern}/
  end

  def is_inside_malloc(bt = get_bt)
    if any_caller_match(bt, '(malloc)')
      $stderr.puts "process #{@native_debugger.pid} is currently inside malloc."
      true
    else
      false
    end
  end

  def is_inside_gc(bt = get_bt)
    if any_caller_match(bt, '(gc\.c)')
      $stderr.puts "process #{@native_debugger.pid} is currently in garbage collection phase."
      true
    else
      false
    end
  end

  def need_finish_frame
    bt = get_bt
    is_inside_malloc(bt) || is_inside_gc(bt)
  end

end
