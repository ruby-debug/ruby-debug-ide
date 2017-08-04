module Debugger
  module TimeoutHandler
    def self.restore_timeout
      %Q{
          alias timeout pre_eval_timeout
        }
    end
  end
end

module Timeout
  class << self
    module_eval Debugger::TimeoutHandler.restore_timeout
  end
end