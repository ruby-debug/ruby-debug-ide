#!/usr/bin/env ruby

require 'rd_test_base'
require 'threads_and_frames_test'

class RDThreadsAndFrames < RDTestBase

  include ThreadsAndFrames

end

class RDUNIXThreadsAndFrames < RDTestBase
  include TestBase::UseUNIXDomainSocket
  include ThreadsAndFrames
end