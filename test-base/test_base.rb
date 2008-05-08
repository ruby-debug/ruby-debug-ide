#!/usr/bin/env ruby

DIR_NAME = File.dirname(__FILE__)
$:.unshift File.join(DIR_NAME, "..", "lib")

require 'fileutils'
require 'socket'
require 'readers'
require 'test/unit'
require 'tmpdir'
require 'open3'
require 'yaml'

# XXX: User proper synchronization.
class TestBase < Test::Unit::TestCase

  attr_accessor :started
  
  TMP_DIR = File.join(Dir.tmpdir, "ruby-debug-ide", self.name)
  
  include Readers
  
  def initialize(name)
    super(name)
    @started = false
    @socket = nil
    @parser = nil
    @fast_fail = nil
  end

  def setup
    $stderr.sync = true
    $stdout.sync = true
    $stdout.printf "\nRunning #{self.name}\n"
    @debug = config_load('debug')
    @verbose_server = config_load('verbose_server')
    @process_finished = false

    # XXX: tmpdir unique to test, probably parse out from self.name
    FileUtils.mkdir_p(TMP_DIR)
  end
  
  # Loads key from the _config_._yaml_ file.
  def config_load(key, may_be_nil=false)
    conf = File.join(DIR_NAME, '..', 'config.private.yaml')
    conf = File.join(DIR_NAME, '..', 'config.yaml') unless File.exists?(conf)
    value = YAML.load_file(conf)[key]
    assert_not_nil(value, "#{key} is set in config.yaml") unless may_be_nil
    value
  end

  def default_test
    @process_finished = true
  end
  
  def teardown
    unless @fast_fail # much faster fail
      debug "Waiting for the server process to finish..."
      (config_load('server_start_up_timeout')*4).times do
        unless @process_finished
          debug '.'
          sleep 0.25
          next
        end
        break
      end
      debug "\n"
      fail("server process did not finish") unless @process_finished
    end
  end
  
  def interpreter
    config_load('interpreter')
  end
  
  def jruby?
    config_load('is_jruby')
  end

  def debug_jruby?
    config_load('debug_jruby')
  end

  def start_ruby_process(script)
    check_free_socket
    cmd = debug_command(script)
    debug "Starting: #{cmd}\n"
    
    Thread.new do
      (_, p_out, p_err) = Open3.popen3(cmd)
      @process_finished = false
      out_t = Thread.new do
        p_out.each do |line|
          $stdout.printf("SERVER OUT: " + line) if @verbose_server
        end
      end
      err_t = Thread.new do
        p_err.each do |line|
          $stdout.printf("SERVER ERR: " + line) if @verbose_server
        end
      end
      out_t.join
      err_t.join
      fail "ERROR: \"#{process}\" failed with exitstatus=#{$?.exitstatus}" unless $?.success?
      @process_finished = true
    end
    
  end
  
  def start_debugger
    started = true
  end
  
  # Rather hack. Probably generates unique port for every test like in an IDE.
  def check_free_socket
    begin
      TCPServer.new('127.0.0.1', 1098).close
    rescue Errno::EADDRINUSE
      @fast_fail = true
      raise
    end
  end

  def create_file(script_name, lines)
    script_path = File.join(TMP_DIR, script_name)
    File.open(script_path, "w") do |script|
      script.printf(lines.join("\n"))
    end
    script_path
  end

  def create_test2(lines)
    @test2_name = "test2.rb"
    @test2_path = create_file(@test2_name, lines)
  end

  # Creates test.rb with the given lines, set up @test_name and @test_path
  # variables and then start the process.
  def create_socket(lines)
    @test_name = "test.rb"
    @test_path = create_file(@test_name, lines)
    start_ruby_process(@test_path)
  end

  def socket
    unless @socket or @process_finished
      debug "Trying to connect to the debugger..."
      (config_load('server_start_up_timeout')*4).downto(1) do |i|
        begin
          @socket = TCPSocket.new("127.0.0.1", 1098)
          break
        rescue Errno::ECONNREFUSED
          debug '.'
          sleep 0.5
        end
      end
      debug "\n"
      fail "Cannot connect to the server" unless @socket
    end
    @socket
  end

  def parser
    assert(!@process_finished, "Ruby debugger has finished prematurely.")
    @parser = REXML::Parsers::PullParser.new(socket) unless @parser
    @parser
  end

  def send_ruby(debugger_command)
    assert(!@process_finished, "Ruby debugger has finished prematurely.")
    debug("Sending: #{debugger_command}\n")
    socket.printf(debugger_command + "\n")
  end

  def send_cont
    send_ruby("cont")
  end

  def send_next
    send_ruby("next")
  end

  def send_step
    send_ruby("step")
  end

  def send_test_breakpoint(line)
    send_ruby("b #{@test_name}:#{line}")
  end

  def run_to(filename, line_number)
    send_ruby("b #{filename}:#{line_number}")
    read_breakpoint_added_no
    if started
      send_cont
    else
      start_debugger 
    end
    assert_breakpoint(filename, line_number)
  end

  def run_to_line(line_number)
    run_to(@test_name, line_number)
  end

  def assert_suspension(exp_file, exp_line, exp_frames, exp_thread_id=1)
    suspension = read_suspension
    assert_equal(exp_file, suspension.file)
    assert_equal(exp_line, suspension.line)
    assert_equal(exp_frames, suspension.frames)
    assert_equal(exp_thread_id, suspension.threadId)
  end

  def assert_breakpoint_added_no(exp_number)
    assert_equal(exp_number, read_breakpoint_added_no)
  end

  def assert_breakpoint_deleted(exp_number)
    breakpoint_deleted = read_breakpoint_deleted
    assert_equal(exp_number, breakpoint_deleted.number)
  end

  def assert_breakpoint(exp_file, exp_line, exp_thread_id = nil)
    breakpoint = read_breakpoint
    assert_equal(exp_file, breakpoint.file, "correct file")
    assert_equal(exp_line, breakpoint.line, "correct line")
    assert_equal(exp_thread_id, breakpoint.threadId, "correct thread") if exp_thread_id
  end

  def assert_test_breakpoint(exp_line, exp_thread_id = nil)
    assert_breakpoint(@test_name, exp_line, exp_thread_id)
  end

  def assert_error
    error = read_error
    assert_not_nil(error)
    assert_not_nil(error.text)
  end

  def assert_message
    message = read_message
    assert_not_nil(message)
    assert_not_nil(message.text)
  end

  def debug(message)
    $stdout.printf(message) if @debug
  end

end
