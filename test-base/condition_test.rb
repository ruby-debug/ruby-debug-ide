#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module ConditionTest

  def test_condition_basics
    create_socket ["1.upto(10) do |i|", "sleep 0.01", "sleep 0.01", "end"]
    send_test_breakpoint(2)
    assert_breakpoint_added_no(1)
    set_condition(1, 'i > 7')
    assert_condition_set(1)
    start_debugger # => i == 3
    assert_test_breakpoint(2)
    send_cont # => i == 6
    assert_test_breakpoint(2)
    send_cont # => i == 9
    assert_test_breakpoint(2)
    send_cont # => finish
  end

end

