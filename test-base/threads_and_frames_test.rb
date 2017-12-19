#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module ThreadsAndFrames

  def test_frames
    create_socket ["require 'test2.rb'", "test = Test2.new()", "test.print()", "test.print()"]
    create_test2 ["class Test2", "def print", "puts 'Test2.print'", "end", "end"]
    run_to("test2.rb", 3)
    send_test_breakpoint(4)
    assert_breakpoint_added_no(2)
    send_ruby("w")
    frames = read_frames

    needed_frame_length = 2
    needed_frame_length += 2 if Debugger::FRONT_END == "debase"
    assert_equal(needed_frame_length, frames.length)

    frame1 = frames[0]
    assert_equal(@test2_path, frame1.file)
    assert_equal(1, frame1.no)
    assert_equal(3, frame1.line)
    frame2 = frames[1]
    assert_equal(@test_path, frame2.file)
    assert_equal(2, frame2.no)
    assert_equal(3, frame2.line)
    send_cont # test2:3 -> test:4
    assert_test_breakpoint(4)
    send_ruby("w")
    frames = read_frames

    needed_frame_length = 1
    needed_frame_length += 2 if Debugger::FRONT_END == "debase"

    assert_equal(needed_frame_length, frames.length)
    send_cont # test:4 -> test2:3
    assert_breakpoint("test2.rb", 3)
    send_cont # test2:3 -> finish
  end

  def test_frames_when_thread_spawned
    if jruby?
      @process_finished = true
      return
    end
    create_socket ["def start_thread", "Thread.new() {  a = 5  }", "end",
        "def calc", "5 + 5", "end", "start_thread()", "calc()"]
    run_to_line(5)
    send_ruby("w")

    needed_length = 2
    needed_length += 2 if Debugger::FRONT_END == "debase"

    assert_equal(needed_length, read_frames.length)
    send_cont
  end
  
end

