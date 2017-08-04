module Timeout
  class << self
    module_eval {
      alias timeout pre_eval_timeout
    }
  end
end