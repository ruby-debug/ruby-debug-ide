#!/usr/bin/env ruby

require 'rd_test_base'
require 'catchpoint_test'

class RDCatchpointTest < RDTestBase

  include CatchpointTest

end

class RDUNIXCatchpointTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include CatchpointTest
end
