require 'rexml/parsers/pullparser'

module Readers

  # Maps to attributes sent by debugger. Therefore camel-case convention for
  # members instead Ruby one.
  Breakpoint = Struct.new("Breakpoint", :file, :line, :threadId)
  BreakpointAdded = Struct.new("BreakpointAdded", :number, :file, :line)
  BreakpointDeleted = Struct.new("BreakpointDeleted", :number)
  BreakpointEnabled = Struct.new("BreakpointEnabled", :bp_id)
  BreakpointDisabled = Struct.new("BreakpointDisabled", :bp_id)
  ConditionSet = Struct.new("ConditionSet", :bp_id)
  CatchpointSet = Struct.new("CatchpointSet", :exception)
  DebugError = Struct.new("Error", :text)
  ProcessingException = Struct.new("Exception", :type, :message)
  DebugMessage = Struct.new("Message", :text)
  Suspension = Struct.new("Suspension", :file, :line, :frames, :threadId)
  DebugException = Struct.new("DebugException", :file, :line, :type, :message, :threadId)
  RubyThread = Struct.new("RubyThread", :id, :status)
  Frame = Struct.new("Frame", :no, :file, :line)
  Variable = Struct.new("Variable", :name, :kind, :value, :type, :hasChildren, :objectId)
  ExpressionInfo = Struct.new("ExpressionInfo", :incomplete, :prompt, :indent)

  def read_breakpoint_added
    (@breakpoint_added_reader ||= BreakPointAddedReader.new(parser)).read
  end

  def read_breakpoint_deleted
    (@breakpoint_deleted_reader ||= BreakpointDeletedReader.new(parser)).read
  end

  def read_breakpoint_enabled
    (@breakpoint_enabled_reader ||= BreakpointEnabledReader.new(parser)).read
  end

  def read_breakpoint_disabled
    (@breakpoint_disabled_reader ||= BreakpointDisabledReader.new(parser)).read
  end

  def read_breakpoint
    (@breakpoint_reader ||= BreakpointReader.new(parser)).read
  end

  def read_condition_set
    (@condition_set_reader ||= ConditionSetReader.new(parser)).read
  end

  def read_catchpoint_set
    (@catchpoint_set_reader ||= CatchpointSetReader.new(parser)).read
  end

  def read_suspension
    (@suspension_reader ||= SuspensionReader.new(parser)).read
  end

  def read_exception
    (@exception_reader ||= ExceptionReader.new(parser)).read
  end

  def thread_info_reader
    @thread_info_reader ||= ThreadsReader.new(parser)
  end

  def read_thread
    thread_info_reader.read_thread
  end

  def read_threads
    thread_info_reader.read
  end

  def read_frames
    (@frames_reader ||= FramesReader.new(parser)).read
  end

  def read_variables
    (@variables_reader ||= VariablesReader.new(parser)).read
  end

  def read_error
    (@error_reader ||= ErrorReader.new(parser)).read
  end

  def read_message
    (@message_reader ||= MessageReader.new(parser)).read
  end

  def read_processing_exception
    (@processing_exception_reader ||= ProcessingExceptionReader.new(parser)).read
  end

  def read_expression_info
    (@expression_info_reader ||= ExpressionInfoReader.new(parser)).read
  end

  def parser
    fail '"parser" method must be defined'
  end

  class BaseReader

    # Hint: event[0] -> type, event[1] -> data

    def initialize(parser)
      @parser = parser
    end

    def read_element_data(expected_element)
      event = read_start_element(expected_element)
      ensure_end_element(expected_element)
      event[1]
    end

    def read_start_element(expected_element)
      event = @parser.pull
      check_event(:start_element, expected_element, event)
      event
    end

    def read_text
      event = @parser.pull
      fail("expected \":text\" event, but got \"#{event.inspect}\"") unless event.text? || event.cdata?
      event[0]
    end

    def ensure_end_element(expected_element)
      event = @parser.pull
      check_event(:end_element, expected_element, event)
    end

    def check_event(expected_type, expected_element, actual_event)
      unless actual_event.event_type == expected_type and actual_event[0] == expected_element
        fail("expected \"#{expected_element}\" #{expected_type}, but got \"#{actual_event.inspect}\"")
      end
    end

  end

  class SuspensionReader < BaseReader
    def read
      data = read_element_data('suspended')
      Suspension.new(data['file'], Integer(data['line']), Integer(data['frames']), Integer(data['threadId']))
    end
  end

  class ExceptionReader < BaseReader
    def read
      data = read_element_data('exception')
      DebugException.new(data['file'], Integer(data['line']), data['type'], data['message'], Integer(data['threadId']))
    end
  end

  class BreakpointReader < BaseReader
    def read
      data = read_element_data('breakpoint')
      Breakpoint.new(data['file'], Integer(data['line']), Integer(data['threadId']))
    end
  end

  class BreakpointDeletedReader < BaseReader
    def read
      data = read_element_data('breakpointDeleted')
      BreakpointDeleted.new(Integer(data['no']))
    end
  end

  class BreakpointEnabledReader < BaseReader
    def read
      data = read_element_data('breakpointEnabled')
      BreakpointEnabled.new(Integer(data['bp_id']))
    end
  end

  class BreakpointDisabledReader < BaseReader
    def read
      data = read_element_data('breakpointDisabled')
      BreakpointDisabled.new(Integer(data['bp_id']))
    end
  end

  class BreakPointAddedReader < BaseReader
    def read
      data = read_element_data('breakpointAdded')
      /(.*):(.*)/ =~ data['location']
      BreakpointAdded.new(Integer(data['no']), $1, $2)
    end
  end

  class ConditionSetReader < BaseReader
    def read
      data = read_element_data('conditionSet')
      ConditionSet.new(Integer(data['bp_id']))
    end
  end

  class CatchpointSetReader < BaseReader
    def read
      data = read_element_data('catchpointSet')
      CatchpointSet.new(data['exception'])
    end
  end

  class ThreadsReader < BaseReader

    def read
      read_start_element('threads')
      threads = []
      loop do
        event = @parser.pull
        case event.event_type
        when :start_element
          check_event(:start_element, 'thread', event)
          ensure_end_element('thread')
          data = event[1]
          threads << RubyThread.new(Integer(data['id']), data['status'])
        when :end_element
          check_event(:end_element, 'threads', event)
          break
        else
          raise "unexpected event #{event.inspect}"
        end
      end
      threads
    end

    def read_thread
      data = read_element_data('thread')
      RubyThread.new(Integer(data['id']), data['status'])
    end

  end

  class VariablesReader < BaseReader
    def read
      read_start_element('variables')
      variables = []
      loop do
        event = @parser.pull
        case event.event_type
        when :start_element
          check_event(:start_element, 'variable', event)
          value_event = @parser.pull
          if value_event.event_type == :start_element
            check_event(:start_element, 'value', value_event)
            text_value = read_text
            ensure_end_element('value')
            ensure_end_element('variable')
          else
            text_value = event[1]['value']
            check_event(:end_element, 'variable', value_event)
          end
          variables << Variable.new(*Variable.members.map { |m|
            value = event[1][m.to_s]
            if m.to_s == 'hasChildren'
              value == 'true'
            elsif m.to_s == 'value'
              text_value
            else
              value
            end
          })
        when :end_element
          check_event(:end_element, 'variables', event)
          break
        else
          raise "unexpected event #{event.inspect}"
        end
      end
      variables
    end
  end

  class FramesReader < BaseReader
    def read
      read_start_element('frames')
      frames = []
      loop do
        event = @parser.pull
        case event.event_type
        when :start_element
          check_event(:start_element, 'frame', event)
          ensure_end_element('frame')
          data = event[1]
          frames << Frame.new(Integer(data['no']), data['file'], Integer(data['line']))
        when :end_element
          check_event(:end_element, 'frames', event)
          break
        else
          raise "unexpected event #{event.inspect}"
        end
      end
      frames
    end
  end

  class ErrorReader < BaseReader
    def read
      read_start_element('error')
      error_text = read_text
      raise("no text for 'error' element") unless error_text
      ensure_end_element('error')
      DebugError.new(error_text)
    end
  end
  
  class MessageReader < BaseReader
    def read
      read_start_element('message')
      message_text = read_text
      raise("no text for 'message' element") unless message_text
      ensure_end_element('message')
      DebugMessage.new(message_text)
    end
  end
  
  class ProcessingExceptionReader < BaseReader
    def read
      data = read_element_data('processingException')
      ProcessingException.new(data['type'], data['message'])
    end
  end

  class ExpressionInfoReader < BaseReader
    def read
      data = read_element_data("expressionInfo")
      ExpressionInfo.new(data['incomplete'], data['prompt'], data['indent'])
    end
  end

end
