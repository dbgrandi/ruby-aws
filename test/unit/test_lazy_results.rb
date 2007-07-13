# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/util/lazy_results'

class TestLazyResults < Test::Unit::TestCase
  include Amazon::Util

  def setup
    @call_count = 0
    @simple_pagesize = 2
    @simple_data_size = 6
    @simple_data = [ [1,2],[3,4],[5,6] ]
    @simple_lazy = LazyResults.new {|page| @call_count += 1 ; @simple_data[ page-1 ] }
  end

  def testBasic
    assert_equal 0, @call_count
    assert_equal @simple_data.flatten, @simple_lazy.to_a
    assert_equal 4, @call_count
    assert_equal @simple_data.flatten, @simple_lazy.to_a
    assert_equal 4, @call_count
    assert_equal Array, @simple_lazy.to_a.class
  end

  def testEnumerable
    result = @simple_lazy.collect
    assert_equal @simple_data.flatten, result
    assert_equal 4, @call_count
    result = @simple_lazy.collect
    assert_equal @simple_data.flatten, result
    assert_equal 4, @call_count
    minus1 = @simple_lazy.collect {|i| i-1}
    minus1.each_with_index {|i,n| assert_equal i, n }
    evenodd = @simple_lazy.inject({:even => [],:odd => []}) {|a,num| a[ num % 2 == 0 ? :even : :odd ] << num ; a }
    expected = {:even => [2,4,6], :odd => [1,3,5] } 
    assert_equal expected, evenodd
  end

  def testIncremental
    count = 0
    @simple_lazy.each { |value|
      assert_equal count+1, value 
      assert_equal( (count / @simple_pagesize)+1, @call_count )
      count += 1
    }
    assert_equal 4, @call_count
  end

  def testRandomAccess
    assert_equal 4, @simple_lazy[3]
    assert_equal 2, @call_count
    assert_nil @simple_lazy[@simple_data_size]
    assert_equal 4, @call_count
    10.times do
      index = rand(@simple_data_size+@simple_pagesize)
      assert_equal( ( index >= @simple_data_size ? nil : index+1 ), @simple_lazy[index] )
    end
    assert_equal 4, @call_count
    assert_equal @simple_data.flatten, @simple_lazy.to_a
  end

  def testFlush
    @simple_lazy.to_a
    @simple_lazy.to_a
    assert_equal 4, @call_count
    @simple_lazy.flush
    @simple_lazy.to_a
    assert_equal 8, @call_count
  end

  def testError
    @picky_message = "picky picky picky"
    @picky_lazy = LazyResults.new {|page| @call_count += 1 ; if page < 3 ; @simple_data[ page-1 ] ; else ; raise @picky_message ; end }
    assert_equal 4, @picky_lazy[3]
    e = assert_raises( RuntimeError ) { @picky_lazy[4] }
    assert_equal @picky_message, e.message
  end

  def testImmutability
    assert_equal 3, @simple_lazy[2]
    a = @simple_lazy.to_a
    assert_equal 3, a[2]
    a[2] = 7
    assert_equal 3, @simple_lazy[2]
  end

end
