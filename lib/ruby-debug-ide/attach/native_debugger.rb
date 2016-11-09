class NativeDebugger

  attr_reader :pid, :main_thread, :process_threads, :pipe

  # @param executable -- path to ruby interpreter
  # @param pid -- pid of process you want to debug
  # @param flags -- flags you want to specify to your debugger as a string (e.g. "-nx -nh" for gdb to disable .gdbinit)
  def initialize(executable, pid, flags, gems_to_include, debugger_loader_path, argv)
    @pid = pid
    @delimiter = '__OUTPUT_FINISHED__' # for getting response
    @tbreak = '__func_to_set_breakpoint_at'
    @main_thread = nil
    @process_threads = nil
    debase_path = gems_to_include.select {|gem_path| gem_path =~ /debase/}
    if debase_path.size == 0
      raise 'No debase gem found.'
    end
    @path_to_attach = find_attach_lib(debase_path[0])

    @gems_to_include = '["' + gems_to_include * '", "' + '"]'
    @debugger_loader_path = debugger_loader_path
    @argv = argv

    @eval_string = "debase_rb_eval(\"require '#{@debugger_loader_path}'; load_debugger(#{@gems_to_include.gsub("\"", "'")}, #{@argv.gsub("\"", "'")})\")"

    launch_string = "#{self} #{executable} #{flags}"
    @pipe = IO.popen(launch_string, 'r+')
    $stdout.puts "executed '#{launch_string}'"
  end

  def find_attach_lib(debase_path)
    attach_lib = debase_path + '/attach'
    known_extensions = %w(.so .bundle .dll .dylib)
    known_extensions.each do |ext|
      if File.file?(attach_lib + ext)
        return attach_lib + ext
      end
    end

    raise 'Could not find attach library'
  end

  def attach_to_process
    execute "attach #{@pid}"
  end

  def execute(command)
    @pipe.puts command
    $stdout.puts "executed `#{command}` command inside #{self}."
    if command == 'q'
      return ''
    end
    get_response
  end

  def get_response
    # we need this hack to understand that debugger gave us all output from last executed command
    print_delimiter

    content = ''
    loop do
      line = @pipe.readline
      DebugPrinter.print_debug('respond line: ' + line)
      break if check_delimiter(line)
      next if line =~ /\(lldb\)/ # lldb repeats your input to its output
      content += line
    end

    content
  end

  def update_threads

  end

  def check_already_under_debug

  end

  def print_delimiter

  end

  def check_delimiter(line)

  end

  def switch_to_thread

  end

  def set_break(str)

  end

  def continue
    $stdout.puts 'continuing'
    @pipe.puts 'c'
    loop do
      line = @pipe.readline
      DebugPrinter.print_debug('respond line: ' + line)
      break if line =~ /#{Regexp.escape(@tbreak)}/
    end
    get_response
  end

  def call_start_attach
    raise 'No main thread found. Did you forget to call `update_threads`?' if @main_thread == nil
    @main_thread.switch
  end

  def wait_line_event
    call_start_attach
    continue
  end

  def load_debugger

  end

  def exited?
    @pipe.closed?
  end

  def exit
    @pipe.close
  end

  def to_s
    'native_debugger'
  end

end
