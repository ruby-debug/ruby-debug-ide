#!/usr/bin/env ruby

require 'rd_test_base'
require 'enable_disable_test'

class RDEnableDisableTest < RDTestBase

  include EnableDisableTest

end

class RDUNIXEnableDisableTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include EnableDisableTest
end
