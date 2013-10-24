module Debugger
  module MultiProcess
    class << self
      def pre_child

        require 'socket'
        require 'ostruct'

        host = ENV['DEBUGGER_HOST']
        port = find_free_port(host)

        options = OpenStruct.new(
            'frame_bind'  => false,
            'host'        => host,
            'load_mode'   => false,
            'port'        => port,
            'stop'        => false,
            'tracing'     => false,
            'int_handler' => true,
            'cli_debug'   => (ENV['DEBUGGER_CLI_DEBUG'] == 'true')
        )

        acceptor_host, acceptor_port = ENV['IDE_PROCESS_DISPATCHER'].split(":")
        acceptor_host, acceptor_port = '127.0.0.1', acceptor_host unless acceptor_port

        connected = false
        3.times do |i|
          begin
            s = TCPSocket.open(acceptor_host, acceptor_port)
            s.print(port)
            s.close
            connected = true
            start_debugger(options)
            return
          rescue => bt
            $stderr.puts "#{Process.pid}: connection failed(#{i+1})"
            $stderr.puts "Exception: #{bt}"
            $stderr.puts bt.backtrace.map { |l| "\t#{l}" }.join("\n")
            sleep 0.3
          end unless connected
        end
      end

      def start_debugger(options)
        if Debugger.started?
          # we're in forked child, only need to restart control thread
          Debugger.breakpoints.clear
          Debugger.control_thread = nil
          Debugger.start_control(options.host, options.port)
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