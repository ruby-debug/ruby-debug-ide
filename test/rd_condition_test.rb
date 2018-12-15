#!/usr/bin/env ruby

require 'rd_test_base'
require 'condition_test'

class RDConditionTest < RDTestBase

  include ConditionTest

end

class RDUNIXConditionTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include ConditionTest
end
