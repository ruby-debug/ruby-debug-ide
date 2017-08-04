module Debugger
  module TimeoutHandler
    def self.create_mp_timeout
      %q{
        alias pre_eval_timeout timeout

        def timeout(sec, klass = nil)   #:yield: +sec+
          return yield(sec) if sec == nil or sec.zero?
          message = "execution expired".freeze
          from = "from #{caller_locations(1, 1)[0]}" if $DEBUG
          e = Error
          bl = proc do |exception|
            begin
              x = Thread.current
              y = Debugger::DebugThread.start {
                Thread.current.name = from
                begin
                  sleep sec
                rescue => e
                  x.raise e
                else
                  x.raise exception, message
                end
              }
              return yield(sec)
            ensure
              if y
                y.kill
                y.join # make sure y is dead.
              end
            end
          end
          if klass
            begin
              bl.call(klass)
            rescue klass => e
              bt = e.backtrace
            end
          else
            bt = Error.catch(message, &bl)
          end
          level = -caller(CALLER_OFFSET).size-2
          while THIS_FILE =~ bt[level]
            bt.delete_at(level)
          end
          raise(e, message, bt)
        end
      }
    end
  end
end

module Timeout
  class << self
    module_eval Debugger::TimeoutHandler.create_mp_timeout
  end
end