require 'thread'

class TCPSocket
  
  # Workaround for JRuby issue http://jira.codehaus.org/browse/JRUBY-2063
  def non_blocking_gets
    loop do
      result, _, _ = IO.select( [self], nil, nil, 0.2 )
      next unless result
      return result[0].gets
    end
  end
  
end

module Debugger  
  class Interface
  end

  class LocalInterface < Interface
  end


  class RemoteInterface < Interface # :nodoc:
    attr_accessor :command_queue
    #attr_accessor :socket

    def initialize(socket)
      @socket = socket
      class <<@socket
        alias close_without_logging close
        def close
          close_without_logging
          $stderr.puts "medvedko is " + ::Kernel.caller(1).join("\n")
        end
      end
      @command_queue = Queue.new
    end
    
    def read_command
      result = @socket.non_blocking_gets
      raise IOError unless result
      result.chomp
    end

    def print(*args)
      @socket.printf(*args)
    end
    
    def close
      @socket.close
    rescue Exception
    end
    
  end
  
end
