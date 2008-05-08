#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module BasicTest

  def test_exit_command
    create_socket ['sleep 0.1', 'sleep 0.1', 'sleep 0.1']
    run_to_line(1)
    send_ruby("exit")
    message = read_message
    assert_equal("finished", message.text)
    sleep 1
    assert(@process_finished, "'exit' command succeed")
  end

end

