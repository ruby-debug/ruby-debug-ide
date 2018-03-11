#!/usr/bin/env ruby

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'

module InspectTest

  def test_inspect
    create_socket ["class Test", "def calc(a)", "a = a*2", "return a",
        "end", "end", "test=Test.new()", "a=3", "test.calc(a)"]
    run_to_line(4)
    # test variable value in stack 1 (top stack frame)
    send_ruby("frame 1; v inspect a*2")
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("12", variables[0].value, "Result in frame 1 is 12")
    # test variable value in stack 2 (caller stack)
    send_ruby("frame 2; v inspect a*2")
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal(variables[0].value, "6", "Result in frame 2 is 6")
    # test more complex expression
    send_ruby("frame 1; v inspect Test.new().calc(5)")
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("10", variables[0].value, "Result is 10")
    send_ruby("cont")
  end

  def test_inspect_nil
    create_socket ["puts 'dummy'", "puts 'dummy'"]
    run_to_line(2)
    send_ruby("v inspect nil")
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned which is nil.")
    assert_equal(nil, variables[0].value)
    send_ruby("cont")
  end

  def test_inspect_error_1
    create_socket ["puts 'test'", "puts 'test'"]
    run_to_line(2)
    send_ruby("v inspect a*2")
    variables = read_variables
    assert_equal(1, variables.length, "There is one exception returned.")
    assert_equal("exception", variables[0].kind, "Result is exception")
    send_cont
  end

  def test_inspect_error_2
    create_socket ["sleep 0.1"]
    run_to_line(1)
    send_ruby('v inspect 1 {1 => "one", 2 => "two" {')
    variables = read_variables
    assert_equal(1, variables.length, "There is one exception returned.")
    assert_equal("exception", variables[0].kind, "Result is exception")
    send_cont
  end

  def test_inspect_expr_with_timeout
    create_socket ["require 'timeout'", "puts 'test'"]
    run_to_line(2)
    send_ruby("v inspect (Timeout::timeout(10) { nil })")
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned which is nil.")
    assert_equal(nil, variables[0].value)
    send_cont
  end

  def test_inspect_failing_expr_with_timeout
    create_socket ["require 'timeout'", "puts 'test'"]
    run_to_line(2)
    send_ruby("v inspect (Timeout::timeout(0.1) { sleep 0.2 })")
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned which is nil.")
    assert_equal("Timeout::Error", variables[0].type)
    send_cont
  end

  def test_inspect_multiline_expression
    create_socket ["sleep 0.1"]
    run_to_line(1)
    send_ruby('v inspect false\\ntrue')
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("true", variables[0].value, "Result is true")
    send_cont
  end

  def test_inspect_unescaping_escaped_newlines
    create_socket ["sleep 0.1"]
    run_to_line(1)

    send_ruby('v inspect "\\\\n".size')
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("1", variables[0].value, "There is one char (newline)")

    send_ruby('v inspect "\\\\\\n".size')
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("0", variables[0].value, "There are no chars, it's line continuation here")

    send_ruby('v inspect "\\\\\\\\\\n".size')
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("2", variables[0].value, "There are two chars: escaped backslash and newline")

    send_ruby('v inspect \'"\\\\n\'.size')
    variables = read_variables
    assert_equal(1, variables.length, "There is one variable returned.")
    assert_equal("3", variables[0].value, "There are three chars: quote, backslash and n")

    send_cont
  end

end

