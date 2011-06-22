require 'basic_test'
require 'rd_test_base'

class RDFrameSegfaultTest < RDTestBase
  def test_segfault
    create_socket ['class Bar',
                     'define_method "boo" do |*params|',
                       '"boo"',
                     'end',
                   'end',
                   'def foo(bar)',
                     'a = []',
                   'end',
                   'bar = Bar.new',
                   'foo(bar.boo)'
                   ]
    run_to_line(7)
    send_ruby("w")
    read_frames
    send_cont
  end
end