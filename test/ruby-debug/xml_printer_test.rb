$:.unshift File.join(File.dirname(__FILE__),'..','lib')

require 'test/unit'
require 'ruby-debug'

class XmlPrinterTest < Test::Unit::TestCase

  def teardown
    Debugger.xml_debug = false
  end

  def test_print_msg
    interface = MockInterface.new
    printer = Debugger::XmlPrinter.new(interface)
    printer.print_msg('%s test', 'message')
    assert_equal(['<message>message test</message>'], interface.data)
  end

  def test_print_msg_with_debug
    Debugger.xml_debug = true
    interface = MockInterface.new
    printer = Debugger::XmlPrinter.new(interface)
    printer.print_msg('%s test', 'message')
    expected = ["<message>message test</message>"]
    assert_equal(expected, interface.data)
  end

  def test_print_debug
    Debugger.xml_debug = true
    interface = MockInterface.new
    printer = Debugger::XmlPrinter.new(interface)
    printer.print_debug('%s test', 'debug message 1')
    printer.print_debug('%s test', 'debug message 2')
    expected = [
        "<message debug='true'>debug message 1 test</message>",
        "<message debug='true'>debug message 2 test</message>"]
    assert_equal(expected, interface.data)
  end

  class MockInterface

    attr_accessor :data

    def initialize
      @data = []
    end
    
    def print(*args)
      @data << format(*args)
    end
    
  end
  
end
