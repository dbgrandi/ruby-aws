# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/util/proactive_results'

class TestProactiveResults < Test::Unit::TestCase
  include Amazon::Util

  def setup
    @call_count = 0
    @exception_count = 0
    @simple_pagesize = 2
    @simple_data_size = 6
    @simple_data = [ [1,2],[3,4],[5,6] ]
    @simple_proactive = ProactiveResults.new {|page| @call_count += 1 ; @simple_data[ page-1 ] }
  end

  def testBasic
    assert @call_count >= 0
    assert_equal @simple_data.flatten, @simple_proactive.to_a
    assert_equal 6, @call_count
    assert_equal @simple_data.flatten, @simple_proactive.to_a
    assert_equal 6, @call_count
    assert_equal Array, @simple_proactive.to_a.class
  end

  def testEnumerable
    result = @simple_proactive.collect
    assert_equal @simple_data.flatten, result
    assert_equal 6, @call_count
    result = @simple_proactive.collect
    assert_equal @simple_data.flatten, result
    assert_equal 6, @call_count
    minus1 = @simple_proactive.collect {|i| i-1}
    minus1.each_with_index {|i,n| assert_equal i, n }
    evenodd = @simple_proactive.inject({:even => [],:odd => []}) {|a,num| a[ num % 2 == 0 ? :even : :odd ] << num ; a }
    expected = {:even => [2,4,6], :odd => [1,3,5] } 
    assert_equal expected, evenodd
  end

  def testIncremental
    count = 0
    remaining = @simple_data.flatten
    @simple_proactive.each { |value|
      assert_not_nil value
      assert_not_nil remaining.delete( value )
      assert @call_count >= (count / @simple_pagesize)+1
      count += 1
    }
    assert_equal 6, count
    assert_equal 6, @call_count
  end

  def testRandomAccess
    assert [2,4,6].member?( @simple_proactive[3] )
    assert @call_count >= 2
    assert_nil @simple_proactive[@simple_data_size]
    assert_equal 6, @call_count
    10.times do
      index = rand(@simple_data_size+@simple_pagesize)
      if index >= @simple_data_size
        assert_nil @simple_proactive[index]
      else
        if index % 2 == 0
          assert [1,3,5].member?( @simple_proactive[index] )
        else
          assert [2,4,6].member?( @simple_proactive[index] )
        end
      end
    end
    assert_equal 6, @call_count
    assert_equal @simple_data.flatten, @simple_proactive.to_a.sort
  end

  def testFlush
    @simple_proactive.to_a
    @simple_proactive.to_a
    assert_equal 6, @call_count
    @simple_proactive.flush
    @simple_proactive.to_a
    assert_equal 12, @call_count
  end

  def testError
    @picky_message = "picky picky picky"
    exception_count = 0
    @picky_proactive = ProactiveResults.new(Proc.new {|i| exception_count += 1 }) do |page| 
      @call_count += 1
      if page < 3
        @simple_data[ page-1 ]
      else
        raise @picky_message
      end
    end
    assert_equal @simple_data.flatten[0..3], @picky_proactive.to_a
    assert_equal 3, exception_count
  end

  def testImmutability
    assert_equal 3, @simple_proactive[2]
    a = @simple_proactive.to_a
    assert_equal 3, a[2]
    a[2] = 7
    assert_equal 3, @simple_proactive[2]
  end

end
