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
    @mock.listen do |call|
      case call.name
      when :RegisterHITType
        {:RegisterHITTypeResult => {:HITTypeId => 'mockHITType', :Request => {} } }
      else
        {}
      end
    end

    template = { :Description => 'foo bar', :MaxAssignments => 2, :RequesterAnnotation => "Funky <%= @jazz %>" }
    question = "who what <%= @where %>"
    data_set = [ { :jazz => "LaLa", :where => 1}, {:jazz => nil, :where => 2, :MaxAssignments => 1}, {:jazz => "Poodle", :where => nil} ]

    results = @mturk.createHITs( template, question, data_set )

    assert_equal [], results[:Failed]
    assert_equal 3, results[:Created].size

    ht = @mock.next
    assert_equal :RegisterHITType, ht.name
    assert_equal 'foo bar', ht.request[:Description]
    assert_equal nil, ht.request[:MaxAssignments]

    h1 = @mock.next
    assert_equal :CreateHIT, h1.name
    assert_equal 'mockHITType', h1.request[:HITTypeId]
    assert_equal 2, h1.request[:MaxAssignments]
    assert_equal 'Funky LaLa', h1.request[:RequesterAnnotation]
    assert_equal 'who what 1', h1.request[:Question]

    h2 = @mock.next
    assert_equal :CreateHIT, h2.name
    assert_equal 'mockHITType', h2.request[:HITTypeId]
    assert_equal 1, h2.request[:MaxAssignments]
    assert_equal 'Funky ', h2.request[:RequesterAnnotation]
    assert_equal 'who what 2', h2.request[:Question]

    h3 = @mock.next
    assert_equal :CreateHIT, h3.name
    assert_equal 'mockHITType', h3.request[:HITTypeId]
    assert_equal 2, h3.request[:MaxAssignments]
    assert_equal 'Funky Poodle', h3.request[:RequesterAnnotation]
    assert_equal 'who what ', h3.request[:Question]

    assert_equal nil, @mock.next
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
