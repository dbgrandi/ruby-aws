# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/util/paginated_iterator'

class TestPaginatedIterator < Test::Unit::TestCase
  include Amazon::Util

  def setup
    @call_count = 0
    @simple_pagesize = 2
    @simple_data_size = 6
    @simple_data = [ [1,2],[3,4],[5,6] ]
    @simple_iter = PaginatedIterator.new {|page| @call_count += 1 ; @simple_data[ page-1 ] }
  end

  def testNext
    assert_equal 0, @call_count
    @simple_data.flatten.each do |i|
      assert_equal i, @simple_iter.next
    end
    assert_equal 3, @call_count
    assert !@simple_iter.done
    assert_nil @simple_iter.next
    assert_equal 4, @call_count
    assert @simple_iter.done
  end

  def testRestart
    assert_equal 0, @call_count
    @simple_iter.next until @simple_iter.done
    assert_equal 4, @call_count
    @simple_iter.restart
    assert !@simple_iter.done
    @simple_iter.next until @simple_iter.done
    assert_equal 8, @call_count
  end

  def testEach
    res = []
    @simple_iter.each {|i| res << i }
    assert_equal @simple_data.flatten, res
    assert_equal 4, @call_count
    assert @simple_iter.done
    @simple_iter.each {|i| fail }
  end

  def testError
    @picky_message = "picky picky picky"
    @picky_iter = PaginatedIterator.new {|page| @call_count += 1 ; if page < 3 ; @simple_data[ page-1 ] ; else ; raise @picky_message ; end }
    3.times { @picky_iter.next }
    assert_equal 4, @picky_iter.next
    e = assert_raises( RuntimeError ) { @picky_iter.next }
    assert_equal @picky_message, e.message
  end

end
