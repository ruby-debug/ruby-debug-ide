#!/usr/bin/env ruby

require 'basic_test'
require 'rd_test_base'

class RDSteppingAndBreakpointsTest < RDTestBase

  include BasicTest

end

class RDUNIXSteppingAndBreakpointsTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include BasicTest
end