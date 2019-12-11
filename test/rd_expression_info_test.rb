#!/usr/bin/env ruby

require 'rd_test_base'
require 'expression_info_test'

class RDExpressionInfoTest < RDTestBase

  include ExpressionInfoTest

end

class RDUNIXExpressionInfoTest < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include ExpressionInfoTest
end
