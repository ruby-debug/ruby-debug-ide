#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module ExpressionInfoTest

  def test_info_multiline_expression
    create_socket ["sleep 0.1"]
    run_to_line(1)
    send_ruby('expression_info 1+')
    expression_info = read_expression_info
    assert_equal("true", expression_info.incomplete)

    send_ruby('expression_info 1+\\n1')
    expression_info = read_expression_info
    assert_equal("false", expression_info.incomplete)

    send_ruby('expression_info "')
    expression_info = read_expression_info
    assert_equal("true", expression_info.incomplete)

    send_ruby('expression_info "\\\\"')
    expression_info = read_expression_info
    assert_equal("true", expression_info.incomplete)

    send_ruby('expression_info "\\\\\\n"')
    expression_info = read_expression_info
    assert_equal("false", expression_info.incomplete)

    send_ruby('expression_info def my_meth')
    expression_info = read_expression_info
    assert_equal("true", expression_info.incomplete)
    send_cont
  end

end

