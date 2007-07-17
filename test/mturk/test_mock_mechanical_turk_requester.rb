# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'ruby-aws'
require 'amazon/webservices/util/mock_transport'

class TestMockMechanicalTurkRequester < Test::Unit::TestCase

  def setup
    @mock = Amazon::WebServices::Util::MockTransport.new
    @mturk = Amazon::WebServices::MechanicalTurkRequester.new( :Transport => @mock, :AWSAccessKey => 'bogus', :AWSAccessKeyId => 'fake' )
  end

  def testGetAccountBalance
    res = @mturk.getAccountBalance # using the convenience layer method
    assert_equal nil, res
    res = @mturk.getAccountBalanceRaw({}) # using the raw method ( no default parameters )
    assert_equal nil, res
    res = @mturk.GetAccountBalance # using pass-through method ( no convenience processing )
    assert_equal true, res[:MockResult][:Mock]

    assert_equal 3, @mock.call_buffer.size
    @mock.each do |request| 
      assert_equal :GetAccountBalance, request.name
      assert request.args
      [:AWSAccessKeyId, :Signature, :Timestamp, :Request].each { |key| assert request.args[key]}
      assert_equal( {}, request.request )
    end
  end

  def testCreateHIT
    res = @mturk.createHIT # convenience layer, will auto-populate some default parameters
    res = @mturk.createHITRaw({}) # raw method, no default parameters
    res = @mturk.CreateHIT # pass-through method ( no convenience processing )

    assert_equal 3, @mock.call_buffer.size

    default_call = @mock.next # request from convenience layer
    request = default_call.request
    assert !request.keys.empty?
    expected = [:MaxAssignments, :AssignmentDurationInSeconds, :AutoApprovalDelayInSeconds, :LifetimeInSeconds, :ResponseGroup]
    assert_equal [], request.keys - expected, 'Convenience layer should not populate unexpected arguments'
    assert_equal [], expected - request.keys, 'Convenience layer should populate all expected arguments'

    @mock.each do |call|
      # both remaining calls should have no arguments
      assert_equal( {}, call.request, 'Raw calls should not auto-populate arguments')
    end
  end

  def testCreateHITs
    # TODO
  end

  def testGetHITResults
    # need to set up a listener to feed back hit and assignment attributes for testing results and work with pagination
    assignments_per_hit = 31
    @mock.mock_reply = {:OperationRequest => {}}
    @mock.listen do |call|
      case call.name
      when :GetHIT
        {:HIT => { :HITId => call.request[:HITId], :MockHITAttribute => 'amazing', :Request => {} } }
      when :GetAssignmentsForHIT
        size = call.request[:PageSize]
        num = call.request[:PageNumber]
        index = size * (num-1)
        max = ( assignments_per_hit > index+size ) ? index+size : assignments_per_hit
        res = []
        index.upto(max-1) do |i|
          res << { :HITId => call.request[:HITId], :AssignmentId => i, :MockAssignmentAttribute => 'stunning' }
        end
        { :GetAssignmentsForHITResult => { :Assignment => res, :Request => {} } }
      else
        nil
      end
    end

    list = %w( hitid1 hitid2 amazinghit3 lamehit4 ).collect {|id| { :HITId => id } }
    results = @mturk.getHITResults( list )

    assert_equal assignments_per_hit*list.size, results.size
    results.each { |item|
      assert_not_nil item[:HITId]
      assert_equal 'amazing', item[:MockHITAttribute]
      assert_not_nil item[:AssignmentId]
      assert_equal 'stunning', item[:MockAssignmentAttribute]
    }

  end

  def testAvailableFunds
    # TODO
  end

end
