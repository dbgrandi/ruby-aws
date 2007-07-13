# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/webservices/util/mock_transport'

class TestMockTransport < Test::Unit::TestCase
  include Amazon::WebServices::Util

  SAMPLE_REQUEST = { :speed => :slow }
  SAMPLE_ARGS = { :Auth => :fake, :Request => [SAMPLE_REQUEST] }

  def setup
    @mock = MockTransport.new
  end

  def testBasic
    result = @mock.dance SAMPLE_ARGS

    assert result[:OperationRequest]
    assert result[:MockResult]
    assert_equal SAMPLE_REQUEST, result[:MockResult][:Request]

    request = @mock.call_buffer[0]
    assert request
    assert request.args
    assert request.request
    assert_equal :dance, request.name
    assert_equal SAMPLE_ARGS, request.args
    assert_equal SAMPLE_REQUEST, request.request
  end

  def testListener
    @a = []
    log_listener = proc { |call| @a << call }

    mock = MockTransport.new :MockListener => log_listener
    mock.dance SAMPLE_ARGS

    assert_equal 1, @a.size
    assert_equal SAMPLE_REQUEST, @a.first.request
  end

  def testListenerInjection
    injection_listener = proc {|call| {:Param => :Injected } }

    mock = MockTransport.new :MockListener => injection_listener
    result = mock.dance SAMPLE_ARGS

    assert_equal :Injected, result[:Param], "Should have injected our parameter"
    assert result[:MockResult], "Injection should not have precluded MockResult"
  end

  def testMockReply
    result = @mock.dance SAMPLE_ARGS
    @mock.mock_reply = {:Bogus => :Fun}
    result2 = @mock.dance SAMPLE_ARGS

    assert result[:MockResult]
    assert_nil result2[:MockResult]

    assert_nil result[:Bogus]
    assert result2[:Bogus]
  end

  def testEnumerable

    # should start out with empty buffer
    calls = @mock.collect { |call| call.name }
    assert_equal [], calls

    # now generate 3 calls
    @mock.dance SAMPLE_ARGS
    @mock.fall SAMPLE_ARGS
    @mock.sing SAMPLE_ARGS

    # ensure we got all 3 args in proper order
    calls = @mock.collect { |call| call.name }
    assert_equal [:dance,:fall,:sing], calls

    # should be repeatable
    calls = @mock.collect { |call| call.name }
    assert_equal [:dance,:fall,:sing], calls

    # now flush the buffer and ensure it's empty again
    @mock.flush
    calls = @mock.collect { |call| call.name }
    assert_equal [], calls
  end

  def testNext

    # should start out with empty buffer
    assert_nil @mock.next

    # make a call
    @mock.dance SAMPLE_ARGS

    # call shows up with #next
    n = @mock.next
    assert_equal :dance, n.name

    # should only have been one call in the buffer
    assert_nil @mock.next

    # two more calls
    @mock.fall SAMPLE_ARGS
    @mock.sing SAMPLE_ARGS

    # ensure we get them in proper order
    assert_equal :fall, @mock.next.name
    assert_equal :sing, @mock.next.name

    # and we should have no more
    assert_nil @mock.next

    # after flushing, we should still have none
    @mock.flush
    assert_nil @mock.next

    # add one more call
    @mock.smile SAMPLE_ARGS

    # we should have just one queued up now
    assert_equal :smile, @mock.next.name
    assert_nil @mock.next

  end

end


