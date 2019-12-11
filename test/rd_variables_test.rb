#!/usr/bin/env ruby

require 'rd_test_base'
require 'variables_test'

class RDVariablesTest < RDTestBase

  include VariablesTest

end

class RDUNIXVariablesTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include VariablesTest
end
