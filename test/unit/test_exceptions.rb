# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/webservices/util/unknown_result_exception'
require 'amazon/webservices/util/validation_exception'

class TestExceptions < Test::Unit::TestCase
  include Amazon::WebServices::Util

  def testUnknownString
    @methodName = :Method17
    ex = UnknownResultException.new( RuntimeError.new('superRuntimeError'), @methodName, nil )

    assert_equal "UnknownResultException: got superRuntimeError calling Method17", ex.to_s
  end

  def testValidationString
    @result = { :OperationRequest => {:RequestId=>"aa718afb-a1f2-4812-9962-4058c20d75a8"},
                :HIT => { :Request => { :IsValid=>"False", 
                                        :Errors => { :Error => { :Message => "your xml broke", 
                                                                 :Code    => "AWS.MechanicalTurk.XMLParseError"}
                                                   }
                                      }
                        }
              }
    ex = ValidationException.new( @result )

    assert_equal "ValidationException: AWS.MechanicalTurk.XMLParseError", ex.to_s
  end

end
