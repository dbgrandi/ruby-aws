# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'ruby-aws'
require 'amazon/webservices/util/mock_transport'
require 'timeout'

class TestErrorHandler < Test::Unit::TestCase

  def setup
    @mock = Amazon::WebServices::Util::MockTransport.new
    @mturk = Amazon::WebServices::MechanicalTurkRequester.new( :Transport => @mock, :AWSAccessKey => 'bogus', :AWSAccessKeyId => 'fake' )
  end

  def testTimeoutOnce

    # mock will timeout first time, return success on second call
    toggle = false
   @mock.listen do |call|
     Timeout.timeout(1) do
       if toggle
         toggle = !toggle
       else
         toggle = !toggle
         sleep(5)
       end
      end
      nil
    end

    assert_equal false, toggle
    # invoke a retryable call once, should auto-retry and return success
    @mturk.getAccountBalance
    assert_equal 2, @mock.call_buffer.size, "Should have retried once"
    @mock.each {|call| assert_equal :GetAccountBalance, call.name, "Should have been a GetAccountBalance call" }

    @mock.flush
    assert_equal false, toggle
    # but invoking a non-retryable call will throw an exception
    begin
      @mturk.grantBonus
      fail "Should have thrown an exception"
    rescue Timeout::Error => e
      # expect this exception
    end
    assert_equal true, toggle
    assert_equal :GrantBonus, @mock.next.name
    assert_nil @mock.next
  end

  def testTimeoutAlways

    #mock will always timeout
    @mock.listen do |call|
      Timeout.timeout(1) { sleep(2) }
    end

    begin
      @mturk.searchHITs
      fail "Should have thrown an exception"
    rescue Timeout::Error => e
      # expect this exception
    end

    7.times do
      assert_equal :SearchHITs, @mock.next.name
    end
    assert_nil @mock.next
  end


  def testRuntimeError
    @mock.listen do |call|
      raise "Blah"
    end

    begin
      @mturk.searchHITs
      fail "Should have thrown an exception"
    rescue RuntimeError => e
      assert_equal "Blah", e.to_s
    end
  end

  def testRuntimeErrorThrottled
     @mock.listen do |call|
      raise "Throttled"
    end

    begin
      @mturk.searchHITs
      fail "Should have thrown an exception"
    rescue RuntimeError => e
      assert_equal "Throttled", e.to_s
    end
  end

  def testSOAPFaultError
    arg = (Struct.new :faultcode, :faultstring, :faultactor, :detail).new 
    arg.faultcode = (Struct.new :data).new 'aws:blarg'
    arg.faultstring = (Struct.new :data).new 'blarg blarg blarg'
    s = SOAP::FaultError.new( arg )
    
    @mock.listen do |call|
      raise s
    end

    begin
      @mturk.searchHITs
      fail "Should have thrown an exception"
    rescue SOAP::FaultError => e
      assert_equal s, e
    end
  end

  def testSOAPFaultErrorThrottled
    arg = (Struct.new :faultcode, :faultstring, :faultactor, :detail).new 
    arg.faultcode = (Struct.new :data).new 'aws:Server.ServiceUnavailable'
    arg.faultstring = (Struct.new :data).new 'Hey, give us a break!'
    s = SOAP::FaultError.new( arg )
    
    @mock.listen do |call|
      raise s
    end

    begin
      @mturk.searchHITs
      fail "Should have thrown an exception"
    rescue SOAP::FaultError => e
      assert_equal s, e
    end
  end

end
