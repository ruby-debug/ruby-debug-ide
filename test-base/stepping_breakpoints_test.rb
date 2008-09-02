#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module SteppingAndBreakpointsTest

  def test_breakpoint_add_and_remove
    create_socket ['1.upto(3) {', "puts 'a'", "puts 'b'", "puts 'c'", "}"]
    send_test_breakpoint(2)
    assert_breakpoint_added_no(1)
    send_test_breakpoint(4)
    assert_breakpoint_added_no(2)
    start_debugger
    assert_test_breakpoint(2)
    send_cont # 2 -> 4
    assert_test_breakpoint(4)
    send_cont # 4 -> 2
    assert_test_breakpoint(2)
    send_ruby("delete -1") # unsupported => info message
    assert_error
    send_ruby("delete 100") # error message
    assert_error
    send_ruby("delete 2")
    assert_breakpoint_deleted(2)
    send_cont # 2 -> 2
    assert_test_breakpoint(2)
    send_cont # 2 -> finish
  end

  def test_breakpoints_removing_2_1
    create_socket ["3.times do", "puts 'a'", "puts 'b'", "end"]
    send_test_breakpoint(2)
    assert_breakpoint_added_no(1)
    send_test_breakpoint(3)
    assert_breakpoint_added_no(2)
    start_debugger
    assert_test_breakpoint(2)
    send_cont # -> 3
    assert_test_breakpoint(3)
    send_cont # -> 2
    assert_test_breakpoint(2)
    send_ruby("delete 2")
    assert_breakpoint_deleted(2)
    send_ruby("delete 1")
    assert_breakpoint_deleted(1)
    send_cont # -> finish
  end

  def test_breakpoints_removing_1_2
    create_socket ["3.times do", "puts 'a'", "puts 'b'", "end"]
    send_test_breakpoint(2)
    assert_breakpoint_added_no(1)
    send_test_breakpoint(3)
    assert_breakpoint_added_no(2)
    start_debugger
    assert_test_breakpoint(2)
    send_cont # -> 3
    assert_test_breakpoint(3)
    send_cont # -> 2
    assert_test_breakpoint(2)
    send_ruby("delete 1")
    assert_breakpoint_deleted(1)
    send_ruby("delete 2")
    assert_breakpoint_deleted(2)
    send_cont # -> finish
  end

  def test_breakpoint_on_first_line
    create_socket ["puts 'a'"]
    send_test_breakpoint(1)
    assert_breakpoint_added_no(1)
    start_debugger
    assert_test_breakpoint(1)
    send_cont
  end

  def test_step_over
    create_socket ["puts 'a'", "puts 'b'", "puts 'c'"]
    send_test_breakpoint(2)
    assert_breakpoint_added_no(1)
    start_debugger
    assert_test_breakpoint(2)
    send_next
    assert_suspension(@test_path, 3, 1)
    send_next
  end

  def test_step_over_frames
    create_test2 ["class Test2", "def print", "puts 'XX'", "end", "end"]
    create_socket ["require 'test2.rb'", "puts 'a'", "Test2.new.print"]
    send_test_breakpoint(3)
    assert_breakpoint_added_no(1)
    start_debugger
    assert_test_breakpoint(3)
    send_next
  end

  def test_step_over_frames_value2
    create_test2 ["class Test2", "def print", "puts 'XX'", "puts 'XX'", "end", "end"]
    create_socket ["require 'test2.rb'", "puts 'a'", "Test2.new.print"]
    run_to("test2.rb", 3)
    send_next
    assert_suspension(@test2_path, 4, 2)
    send_next
  end

  def test_step_over_in_different_frame
    create_test2 ["class Test2", "def print", "puts 'XX'", "puts 'XX'", "end", "end"]
    create_socket ["require 'test2.rb'", "Test2.new.print", "puts 'a'"]
    run_to("test2.rb", 4)
    send_next
    assert_suspension(@test_path, 3, 1)
    send_cont
  end

  def test_step_return
    create_test2 ["class Test2", "def print", "puts 'XX'", "puts 'XX'", "end", "end"]
    create_socket ["require 'test2.rb'", "Test2.new.print", "puts 'a'"]
    run_to("test2.rb", 4)
    send_next
    assert_suspension(@test_path, 3, 1)
    send_cont
  end

  def test_step_into
    create_test2 ["class Test2", "def print", "puts 'XX'", "puts 'XX'", "end", "end"]
    create_socket ["require 'test2.rb'", "puts 'a'", "Test2.new.print"]
    run_to_line(3)
    send_step
    assert_suspension(@test2_path, 3, 2)
    send_cont
  end

  def test_simple_cycle_stepping_works
    create_socket ["1.upto(2) {", "puts 'a'", "}", "puts 'b'"]
    send_test_breakpoint(2)
    assert_breakpoint_added_no(1)
    send_test_breakpoint(4)
    assert_breakpoint_added_no(2)
    start_debugger
    assert_test_breakpoint(2)
    send_cont # 2 -> 2
    assert_test_breakpoint(2)
    send_cont # 2 -> 2
    assert_test_breakpoint(4)
    send_cont # 4 -> finish
  end

  def test_spaces_and_semicolon_in_path
    test_name = "path spaces semi:colon.rb"
    test_path = create_file(test_name, ["puts 'a'", "puts 'b'", "puts 'c'"])
    start_ruby_process(test_path)
    send_ruby("b #{test_name}:2")
    assert_breakpoint_added_no(1)
    start_debugger
    assert_breakpoint(test_name, 2, nil)
    send_cont # 2 -> finish
  end

  def test_frames_finish
    create_socket ['def a', 'sleep 0.001', 'sleep 0.001', 'end', 'a', 'sleep 0.001', 'sleep 0.001']
    run_to_line(2)
    send_ruby('fin')
    assert_suspension(@test_path, 6, 1)
    send_cont
  end

end

