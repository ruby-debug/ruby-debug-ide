module Debugger
  module MultiProcess
    class << self
      def pre_child(options = nil)
        require 'socket'
        require 'ostruct'

        host = ENV['DEBUGGER_HOST']

        options ||= OpenStruct.new(
            'frame_bind'  => false,
            'host'        => host,
            'load_mode'   => false,
            'port'        => find_free_port(host),
            'stop'        => false,
            'tracing'     => false,
            'int_handler' => true,
            'cli_debug'   => (ENV['DEBUGGER_CLI_DEBUG'] == 'true'),
            'notify_dispatcher' => true
        )

        if(options.port == -1)
          options.port = find_free_port(options.host)
          options.notify_dispatcher = true
        end
      
        start_debugger(options)
      end

      def start_debugger(options)
        if Debugger.started?
          # we're in forked child, only need to restart control thread
          Debugger.breakpoints.clear
          Debugger.control_thread = nil
          Debugger.start_control(options.host, options.port, options.notify_dispatcher)
        end

        if options.int_handler
          # install interruption handler
          trap('INT') { Debugger.interrupt_last }
        end

        # set options
        Debugger.keep_frame_binding = options.frame_bind
        Debugger.tracing = options.tracing
        Debugger.cli_debug = options.cli_debug
        Debugger.prepare_debugger(options)
      end


      def find_free_port(host)
        server = TCPServer.open(host, 0)
        port   = server.addr[1]
        server.close
        port
      end
    end
  end
end