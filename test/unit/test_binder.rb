# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/util/binder'
                                                                                                                                                                                      
class TestBinder < Test::Unit::TestCase
  include Amazon::Util

  SAMPLE_VARS = { :a => 'pudding', :b => 'pie', :c => 'cheesecake' }

  SAMPLE_TEMPLATE = "I love <%= @b %> (especially with <%= @a %>), but I love <%= @c %> even more!"

  SAMPLE_EXPECTED = "I love pie (especially with pudding), but I love cheesecake even more!"

  def testConstructorConfig
    b = Binder.new( SAMPLE_VARS )
    result = b.erb_eval( SAMPLE_TEMPLATE )
    assert_equal SAMPLE_EXPECTED, result
  end

  def testBuilderConfig
    b = Binder.new { |bb| SAMPLE_VARS.each {|k,v| bb.set( k, v ) } }
    result = b.erb_eval( SAMPLE_TEMPLATE )
    assert_equal SAMPLE_EXPECTED, result
  end

  def testInstanceConfig
    b = Binder.new
    SAMPLE_VARS.each { |k,v| b.set( k, v ) }
    result = b.erb_eval( SAMPLE_TEMPLATE )
    assert_equal SAMPLE_EXPECTED, result
  end

  def testMergeConfig
    b = Binder.new
    b.merge SAMPLE_VARS
    result = b.erb_eval( SAMPLE_TEMPLATE )
    assert_equal SAMPLE_EXPECTED, result
  end

  def testCombinedConfig
    keys = SAMPLE_VARS.keys
    b = Binder.new( keys[0] => SAMPLE_VARS[ keys[0] ] ) { |bb|
      bb.set( keys[1], SAMPLE_VARS[ keys[1] ] ) }
    b.set( keys[2], SAMPLE_VARS[ keys[2] ] )
    result = b.erb_eval( SAMPLE_TEMPLATE )
    assert_equal SAMPLE_EXPECTED, result
  end

  def testConfigPrecedence
    b = Binder.new( SAMPLE_VARS ) { |bb|
      bb.merge( 'a' => 'rhubarb', 'c'=> 'gelato' ) }
    b.merge( :c => 'jello' )
    result = b.erb_eval( SAMPLE_TEMPLATE )
    assert_equal "I love pie (especially with rhubarb), but I love jello even more!", result
  end

  def testMissingVar
    b = Binder.new
    result = silently { b.erb_eval( "Going to the <%=@blue%> moon" ) }
    assert_equal "Going to the  moon", result
  end

  def testScopeCaller
    b = Binder.new
    @arg = "ocean"
    result = silently { b.erb_eval( "swim in the <%= @arg %> seas" ) }
    assert_equal "swim in the  seas", result
  end

  def testScopeBoth
    @zip = '--zip--'
    b = Binder.new( :zip => '++zap++' )
    result = b.erb_eval( "The line went <%= @zip %>" )
    assert_equal "The line went ++zap++", result
  end

  private

  def silently( &block )
    warn_level = $VERBOSE
    $VERBOSE = nil
    result = block.call
    $VERBOSE = warn_level
    result
  end

end
