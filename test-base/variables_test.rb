#!/usr/bin/env ruby
# encoding: utf-8

$:.unshift File.join(File.dirname(__FILE__), "..", "lib")

require 'test_base'
require 'erb'

module VariablesTest

  def test_variable_nil
    create_socket ["puts 'a'", "puts 'b'", "stringA='XX'"]
    run_to_line(2)
    send_ruby("frame 1; v l")
    assert_variables(read_variables, 1, {:name => "stringA", :value => nil})
    send_cont
  end

  def test_variable_with_xml_content
    create_socket ["stringA='<start test=\"&\"/>'",
        "testHashValue=Hash[ '$&' => nil]", "puts 'b'"]
    run_to_line(3)
    send_ruby("frame 1; v l")
    variables = read_variables
    assert_variables(variables, 2,
      {:name => "stringA"},
      {:name => "testHashValue"})
    # will receive ''
    assert_equal(CGI.escapeHTML("<start test=\"&\"/>"), variables[0].value)
    assert_local(variables[0])
    # the testHashValue contains an example, where the name consists of special
    # characters
    send_ruby("v i testHashValue")
    variables = read_variables
    assert_equal(1, variables.length)
    assert_xml("'$&'", variables[0].name)
    send_cont
  end

  def test_variable_in_object
    create_socket ["class Test", "def initialize", "@y=5", "puts @y", "end",
        "def to_s", "'test'", "end", "end", "Test.new"]
    run_to_line(4)
    # Read numerical variable
    send_ruby("frame 1; v l")
    assert_variables(read_variables, 1,
      {:name => "self", :value => "test", :type => "Test", :hasChildren => true})
    send_ruby("v i self")
    assert_variables(read_variables, 1,
      {:name => "@y", :value => "5", :type => "Fixnum", :hasChildren => false, :kind => "instance"})
    send_cont
  end

  def test_class_variables
    create_socket ["class Test", "@@class_var=55", "def method", "puts 'a'",
        "end", "end", "test=Test.new", "test.method"]
    run_to_line(4)
    send_ruby("frame 1; v l")
    assert_variables(read_variables, 1,
      {:name => "self", :hasChildren => true})
    send_ruby("v i self")
    assert_variables(read_variables, 1,
      {:name => "@@class_var", :value => "55", :type => "Fixnum", :kind => "class"})
    send_cont
  end

  def test_singleton_class_variables
    create_socket ["class Test", "def method", "puts 'a'", "end", "class << Test",
        "@@class_var=55", "end", "end", "Test.new.method"]
    run_to_line(3)
    send_ruby("v i self")
    assert_variables(read_variables, 1,
      {:name => "@@class_var", :value => "55", :type => "Fixnum", :hasChildren => false, :kind => "class"})
    send_cont
  end

  def test_variable_string
    create_socket ["stringA='XX'", "puts stringA"]
    run_to_line(2)
    # Read numerical variable
    send_ruby("frame 1; v l")
    assert_variables(read_variables, 1,
      {:name => "stringA", :value => "XX", :type => "String", :hasChildren => true})
    send_cont
  end

  def test_variable_local
    create_socket ["class User", "def initialize(id)",
        "@id=id", "end", "end", "class CallClass", "def method(user)",
        "puts user", "end", "end", "CallClass.new.method(User.new(22))"]
    run_to_line(8)
    send_ruby("frame 1; v local")
    variables = read_variables
    assert_variables(variables, 2)
    assert_not_nil variables[1].objectId
    send_ruby("v i " + variables[1].objectId) # 'user' variable
    assert_variables(read_variables, 1,
      {:name => "@id", :value => "22", :type => "Fixnum", :hasChildren => false})
    send_cont
  end

  def test_variable_instance
    create_socket ["require_relative 'test2.rb'", "custom_object=Test2.new", "puts custom_object"]
    create_test2 ["class Test2", "def initialize", "@y=5", "end", "def to_s", "'test'", "end", "end"]
    run_to("test2.rb", 6)
    frame_number = 3
    frame_number -= 1 if Debugger::FRONT_END == "debase"
    send_ruby("frame #{frame_number}; v i custom_object")
    assert_variables(read_variables, 1,
      {:name => "@y", :value => "5", :type => "Fixnum", :hasChildren => false})
    send_cont
  end

  def test_variable_array
    create_socket ["array = []", "array << 1", "array << 2", "puts 'a'"]
    run_to_line(4)
    send_ruby("frame 1; v local")
    assert_variables(read_variables, 1,
      {:name => "array", :type => "Array", :hasChildren => true})
    send_ruby("v i array")
    assert_variables(read_variables, 2,
      {:name => "[0]", :value => "1", :type => "Fixnum"})
    send_cont
  end

  def test_variable_hash_with_string_keys
    create_socket ["hash = Hash['a' => 'z', 'b' => 'y']", "puts 'a'"]
    run_to_line(2)
    send_ruby("frame 1; v local")
    assert_variables(read_variables, 1,
      {:name => "hash", :hasChildren => true})
    send_ruby("v i hash")
    assert_variables(read_variables, 2,
      {:name => CGI.escape_html("'a'"), :value => "z", :type => "String"})
    send_cont
  end

  def test_variable_hash_with_object_keys
    create_socket ["class KeyAndValue", "def initialize(v)",
        "@a=v", "end", "def to_s", "return @a.to_s", "end", "end",
        "hash = Hash[KeyAndValue.new(55) => KeyAndValue.new(66)]",
        "puts 'a'"]
    run_to_line(10)
    send_ruby("frame 1; v local")
    variables = read_variables
    assert_variables(variables, 1,
      {:name => "hash", :hasChildren => true})
    send_ruby("frame 1 ; v i " + variables[0].objectId)
    elements = read_variables
    assert_variables(elements, 1,
      {:name => "55", :value => "66", :type => "KeyAndValue"})
    # get the value
    send_ruby("frame 1 ; v i " + elements[0].objectId)
    assert_variables(read_variables, 1,
      {:name => "@a", :value => "66", :type => "Fixnum"})
    send_cont
  end

  def test_variable_array_empty
    create_socket ["emptyArray = []", "puts 'a'"]
    run_to_line(2)
    send_ruby("frame 1; v local")
    assert_variables(read_variables, 1,
      {:name => "emptyArray", :hasChildren => false})
    send_cont
  end

  # When to_s returns nil
  def test_nil_from_to_s
    create_socket ["class BugExample; def to_s; nil; end; end", "b = BugExample.new", "sleep 0.01"]
    run_to_line(3)
    send_ruby("v local")
    assert_variables(read_variables, 1, {:value => "nil"})
    send_cont
  end

  # When to_s returns non-string
  def test_non_string_from_to_s
    create_socket ["class BugExample; def to_s; 1; end; end", "b = BugExample.new", "sleep 0.01"]
    run_to_line(3)
    send_ruby("v local")
    assert_variables(read_variables, 1, {:value => "ERROR: BugExample.to_s method returns Fixnum. Should return String."})
    send_cont
  end

  def test_equality_is_not_used
    create_socket ["class A", "def ==(obj)", "obj.non_existent", "end", "end", "a = A.new", "puts a"]
    run_to_line(7)
    send_ruby("v l")
    assert_variables(read_variables, 1)
    send_cont
  end
  
  def test_to_s_raises_exception
    create_socket ['class A', 'def to_s', 'raise "hey"', 'end', 'end', 'a = A.new', 'sleep 0.01']
    run_to_line(7)
    send_ruby('v l')
    assert_variables(read_variables, 1)
    send_cont
  end

  def assert_xml(expected_xml, actual_xml)
    # XXX is there a better way then html_escape in standard libs?
    assert_equal(ERB::Util.html_escape(expected_xml), actual_xml)
  end

  def assert_local(variable)
    assert_equal("local", variable.kind)
  end

  def assert_class(variable)
    assert_equal("class", variable.kind)
  end

  def assert_instance(variable)
    assert_equal("instance", variable.kind)
  end

  def assert_constant(variable)
    assert_equal("constant", variable.kind)
  end

  def assert_type(exp_type, variable)
    assert_equal(exp_type, variable.type)
  end

  def assert_variables(vars, count, *expected)
    assert_equal(count, vars.length, "number of variables")
    expected.each_with_index do |exp_var_hash, i|  
      exp_var_hash.each do |field, value|
        assert_equal(value, vars[i][field], "right value")
      end
    end
  end

end

