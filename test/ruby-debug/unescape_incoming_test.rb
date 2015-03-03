require 'test/unit'
require 'ruby-debug-ide/command'

class UnescaperTest < Test::Unit::TestCase

  def test_empty
    do_test('', '')
    do_test('a', 'a')
  end

  def test_newline
    do_test('\n', "\n")
    do_test('a\n', "a\n")
  end

  def test_escaped_newline
    do_test('\\\\n', '\n')
    do_test('a\\\\n', 'a\n')
  end

  def test_backslash_and_newline
    do_test('\\\\\\n', "\\\n")
    do_test('a\\\\\\n', "a\\\n")
  end

  def test_something
    do_test('hello\nthere\\\\n', "hello\nthere\\n")
    do_test('"\\\\\\n".size', "\"\\\n\".size")
  end

  def do_test(input, expected_result)
    assert_equal(expected_result, Debugger::Command.unescape_incoming(input))
  end
end