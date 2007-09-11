# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/util/binder'
require 'tempfile'
require 'fileutils'
                                                                                                                                                                                      
class TestUserDataStore < Test::Unit::TestCase
  include Amazon::Util

  def setup
    @tmpfile = Tempfile.new('RubyAWSTesting')
    @fakehome = @tmpfile.path + 'homedir'
    FileUtils.mkdir( @fakehome )
    ENV['TEST_HOME_OVERRIDE'] = @fakehome
  end

  def teardown
    ENV.delete 'TEST_HOME_OVERRIDE'
    FileUtils.remove_dir( @fakehome )
    @tmpfile = nil
  end

  def testSimpleValue
    store = UserDataStore.new('TEST_MTURK')
    store.set( :pudding, :color, 'yellow' )
    store.save

    store2 = UserDataStore.new('TEST_MTURK')
    color = store.get :pudding, :color

    assert_equal 'yellow', color, 'pudding was the wrong color'
  end

  def testEmpty
    store = UserDataStore.new('TEST_MTURK')
    color = store.get :pudding, :color
    assert_nil color
  end

  def testClear
    store = UserDataStore.new('TEST_MTURK')
    store.set( :pudding, :color, 'green' )
    store.set( :pudding, :smell, 'sweet' )
    store.save

    store.clear(:pudding)
    store.save

    store2 = UserDataStore.new('TEST_MTURK')
    assert_nil store.get(:pudding,:color)
    assert_nil store.get(:pudding,:smell)
  end

  def testClearPartial
    store = UserDataStore.new('TEST_MTURK')
    store.set( :pudding, :color, 'pink' )
    store.set( :pudding, :smell, 'sour' )
    store.save

    store.clear(:pudding,:smell)
    store.save

    store2 = UserDataStore.new('TEST_MTURK')
    assert_equal 'pink', store.get(:pudding,:color)
    assert_nil store.get(:pudding,:smell)
  end

  def testNamespaces
    store = UserDataStore.new('TEST_MTURK')
    store.set( :pudding, :color, 'purple' )

    same_namespaces = [ :Pudding, :PUDDING, :pUDDING, 'pudding', 'PUDDING', 'PuDDinG' ]
    same_namespaces.each do |ns|
      assert_equal 'purple', store.get(ns,:color)
    end
  end

end
