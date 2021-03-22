require 'test_base'

$:.unshift File.join(File.dirname(__FILE__), "..", "..", "lib")

require 'ruby-debug-ide'

class CommandTest < TestBase
  def with_environment_setting(key, value)
    old_value = ENV[key]
    ENV[key] = value
    begin
      yield
    ensure
      ENV[key] = old_value
    end
  end

  def test_host_and_port
    with_environment_setting('IDE_PROCESS_DISPATCHER', '0.0.0.0:2345') do
      assert_equal(Debugger::Command.host, '0.0.0.0')
      assert_equal(Debugger::Command.port, 2345)
    end

    # Bail if we don't have host:port
    with_environment_setting('IDE_PROCESS_DISPATCHER', '0.0.0.0') do
      assert_equal(Debugger::Command.host, '127.0.0.1')
      assert_equal(Debugger::Command.port, 1234)
    end
  end
end
