module Debugger
  module MultiProcess
    def self.restore_fork
      %Q{
        alias fork pre_debugger_fork
      }
    end

    def self.restore_exec
      %Q{
        alias exec pre_debugger_exec
      }
    end
  end
end

module Kernel
  class << self
    module_eval Debugger::MultiProcess.restore_fork
    module_eval Debugger::MultiProcess.restore_exec
  end
  module_eval Debugger::MultiProcess.restore_fork
  module_eval Debugger::MultiProcess.restore_exec
end

module Process
  class << self
    module_eval Debugger::MultiProcess.restore_fork
    module_eval Debugger::MultiProcess.restore_exec
  end
end