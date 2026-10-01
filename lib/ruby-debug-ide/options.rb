module Debugger
  class DebuggerOptions
    attr_accessor :frame_bind, :host, :load_mode, :port, :stop, :tracing, :skip_wait_for_start, :int_handler,
                  :dispatcher_port, :evaluation_timeout, :trace_to_s, :debugger_memory_limit, :inspect_time_limit,
                  :rm_protocol_extensions, :catchpoint_deleted_event, :value_as_nested_element, :attach_mode,
                  :cli_debug, :key_value_mode, :socket_path, :ignore_port, :notify_dispatcher

    def initialize
      @frame_bind = false
      @host = nil
      @load_mode = false
      @port = 1234
      @stop = false
      @tracing = false
      @skip_wait_for_start = false
      @int_handler = true
      @dispatcher_port = -1
      @evaluation_timeout = 10
      @trace_to_s = false
      @debugger_memory_limit = 10
      @inspect_time_limit = 100
      @rm_protocol_extensions = false
      @catchpoint_deleted_event = false
      @value_as_nested_element = false
      @attach_mode = false
      @cli_debug = false
      @key_value_mode = false
      @socket_path = nil
      @ignore_port = false
      @notify_dispatcher = false
    end

    def to_s
      self.instance_variables.sort.map do |var_name|
        var_value = self.instance_variable_get(var_name)
        [var_name, var_value]
      end.to_h.to_s
    end
  end
end