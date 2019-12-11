#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module CatchpointTest

  def test_catchpoint_basics
    create_socket ['sleep 0.01', '5/0', 'sleep 0.01']
    run_to_line(1)
    send_next
    assert_suspension(@test_path, 2, 1)
    send_ruby('catch ZeroDivisionError')
    assert_catchpoint_set('ZeroDivisionError')
    send_next
    assert_exception(@test_path, 2, 'ZeroDivisionError')
    send_next
  end

end
