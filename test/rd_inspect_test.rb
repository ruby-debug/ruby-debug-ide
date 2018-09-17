#!/usr/bin/env ruby

require 'rd_test_base'
require 'inspect_test'

class RDInspectTest < RDTestBase

  include InspectTest

end

class RDUNIXInspectTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include InspectTest
end
