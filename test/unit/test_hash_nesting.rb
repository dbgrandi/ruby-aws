# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/util/hash_nesting'

class TestHashNesting < Test::Unit::TestCase
  include Amazon::Util

  def setup
    @hash = {}.extend HashNesting
    @nested = { 'a' => 'b', 'c.d' => 'e', 'c.f' => 'g', 'h.1.i' => 'j', 'h.2.k' => 'l' }.extend HashNesting
    @unnested = { :a => 'b', :c => { :d => 'e', :f => 'g' }, :h => [ {:i => 'j'}, {:k => 'l'} ] }.extend HashNesting
  end

  def testSimpleNest
    @hash[:a] = 'b'
    @hash[:p] = { :q => 'r', :s => 't' }
    @hash[:x] = [{:y => 'z'}, {:y => 'w'}]
    nest = @hash.nest
    assert_equal 'b', nest['a']
    assert_equal 'r', nest['p.q']
    assert_equal 't', nest['p.s']
    assert_equal 'z', nest['x.1.y']
    assert_equal 'w', nest['x.2.y']
    assert_equal [], %w( a p.q p.s x.1.y x.2.y) - nest.keys
    assert_equal [], nest.keys - %w( a p.q p.s x.1.y x.2.y)
  end

  def testSimpleUnnest
    @hash['a'] = 'b'
    @hash['p.q'] = 'r'
    @hash['x.1.w'] = 'q'
    @hash['x.2.w'] = 'z'
    unnest = @hash.unnest
    assert_equal 'b', unnest[:a]
    assert_equal 'r', unnest[:p][:q]
    assert_equal 'q', unnest[:x][0][:w]
    assert_equal 'z', unnest[:x][1][:w]
  end

  def testMutability
    cpy = @unnested.dup

    unnest = @unnested.unnest
    assert_equal cpy, @unnested

    nest = @unnested.nest
    assert_equal cpy, @unnested

    @unnested.nest!
    assert_equal @nested, @unnested
    @unnested.unnest!
    assert_equal cpy, @unnested

    @unnested.nest!.unnest!
    assert_equal cpy, @unnested

    assert_equal cpy, @unnested.unnest!

    cpy = @nested.dup

    @nested.unnest!.nest!
    assert_equal cpy, @nested

    assert_equal cpy, @nested.nest!
  end

  def testChaining
    assert_equal @unnested, @nested.unnest.unnest!.unnest
    assert_equal @nested, @unnested.nest.nest!.nest
    assert_equal @nested, @nested.unnest.unnest!.nest!.nest
    assert_equal @unnested, @unnested.nest.nest!.unnest!.unnest
  end

  def testPrecedence
    @hash['a'] = 'b'
    @hash[:a] = 'c'
    @hash[:z] = 'x'
    @hash['z'] = 'y'

    assert_equal 'c', @hash.nest['a']
    assert_equal 'c', @hash.unnest[:a]
    assert_equal 'x', @hash.nest['z']
    assert_equal 'x', @hash.unnest[:z]

    @hash['a'] = 'd'

    assert_equal 'c', @hash.nest['a']
    assert_equal 'c', @hash.unnest[:a]
  end

end
