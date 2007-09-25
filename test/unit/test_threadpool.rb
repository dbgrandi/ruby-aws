# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'amazon/util/threadpool'
                                                                                                                                                                                      
class TestThreadpool < Test::Unit::TestCase
  include Amazon::Util

  def setup
    @tp = ThreadPool.new 5
  end

  def teardown
    @tp.finish
  end

  def testNothing
    assert true
  end
  
  def testDoSomething
    @tp.addWork { sleep(0.1) }
    assert true
  end

  def testSimple
    q = Queue.new

    5.times {|t| @tp.addWork(t) {|i| sleep(rand(4)*0.1) ; q << i } }
    @tp.finish

    s = []
    5.times { s << q.pop }
    assert_equal [0,1,2,3,4], s.sort
  end

  def testSync
    s = []

    5.times { |t| @tp.addWork(t) {|i| s << i } }
    @tp.sync
    assert_equal [0,1,2,3,4], s.sort
    5.times { |t| @tp.addWork(t) {|i| s << i+5 } }
    @tp.sync

    assert_equal [0,1,2,3,4], s[0,5].sort
    assert_equal [5,6,7,8,9], s[5,5].sort
  end

end
