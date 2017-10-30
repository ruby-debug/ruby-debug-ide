require 'timeout'
include Debugger

module Timeout
  class << self
    module_eval {
      alias pre_eval_timeout timeout

      def timeout1_8_7(sec, klass = nil)
        return yield if sec == nil or sec.zero?
        raise ThreadError, "timeout within critical session" if Thread.critical
        exception = klass || Class.new(ExitException)
        begin
          x = Thread.current
          y = DebugThread.start {
            begin
              sleep sec
            rescue => e
              x.raise e
            else
              x.raise exception, "execution expired" if x.alive?
            end
          }
          yield sec
            #    return true
        rescue exception => e
          rej = /\A#{Regexp.quote(__FILE__)}:#{__LINE__-4}\z/o
          (bt = e.backtrace).reject! {|m| rej =~ m}
          level = -caller(CALLER_OFFSET).size
          while THIS_FILE =~ bt[level]
            bt.delete_at(level)
            level += 1
          end
          raise if klass # if exception class is specified, it
          # would be expected outside.
          raise Error, e.message, e.backtrace
        ensure
          if y and y.alive?
            y.kill
            y.join # make sure y is dead.
          end
        end
      end

      def timeout1_9_3(sec, klass = nil) #:yield: +sec+
        return yield(sec) if sec == nil or sec.zero?
        exception = klass || Class.new(ExitException)
        begin
          begin
            x = Thread.current
            y = DebugThread.start {
              begin
                sleep sec
              rescue => e
                x.raise e
              else
                x.raise exception, "execution expired"
              end
            }
            return yield(sec)
          ensure
            if y
              y.kill
              y.join # make sure y is dead.
            end
          end
        rescue exception => e
          rej = /\A#{Regexp.quote(__FILE__)}:#{__LINE__-4}\z/o
          (bt = e.backtrace).reject! {|m| rej =~ m}
          level = -caller(CALLER_OFFSET).size
          while THIS_FILE =~ bt[level]
            bt.delete_at(level)
            level += 1
          end
          raise if klass # if exception class is specified, it
          # would be expected outside.
          raise Error, e.message, e.backtrace
        end
      end

      def timeout2_1_1(sec, klass = nil) #:yield: +sec+
        return yield(sec) if sec == nil or sec.zero?
        message = "execution expired"
        e = Error
        bl = proc do |exception|
          begin
            x = Thread.current
            y = DebugThread.start {
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
          bt = ExitException.catch(message, &bl)
        end
        rej = /\A#{Regexp.quote(__FILE__)}:#{__LINE__-4}\z/o
        bt.reject! {|m| rej =~ m}
        level = -caller(CALLER_OFFSET).size
        while THIS_FILE =~ bt[level]
          bt.delete_at(level)
        end
        raise(e, message, bt)
      end

      def timeout2_3_0(sec, klass = nil) #:yield: +sec+
        return yield(sec) if sec == nil or sec.zero?
        message = "execution expired".freeze
        from = "from #{caller_locations(1, 1)[0]}" if $DEBUG
        e = Error
        bl = proc do |exception|
          begin
            x = Thread.current
            y = DebugThread.start {
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

      if (RUBY_VERSION < '1.9.3')
        alias timeout timeout1_8_7
      elsif (RUBY_VERSION < '2.1.1')
        alias timeout timeout1_9_3
      elsif (RUBY_VERSION < '2.3.0')
        alias timeout timeout2_1_1
      else
        alias timeout timeout2_3_0
      end
    }
  end
end