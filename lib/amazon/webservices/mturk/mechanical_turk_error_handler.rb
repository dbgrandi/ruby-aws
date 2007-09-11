# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'amazon/util/logging'
require 'amazon/webservices/util/validation_exception'
require 'amazon/webservices/util/unknown_result_exception'

module Amazon
module WebServices
module MTurk

class MechanicalTurkErrorHandler
  include Amazon::Util::Logging

  REQUIRED_PARAMETERS = [:Relay]

  # Commands with these prefixes can be retried if we are unsure of success
  RETRY_PRE = %w( search get register update disable assign set dispose )

  # Max number of times to retry a call
  MAX_RETRY = 6

  # Base used in Exponential Backoff retry delay
  BACKOFF_BASE = 2
  # Scale factor for Exponential Backoff retry delay
  BACKOFF_INITIAL = 0.1

  # Matching pattern to find a 'Results' element in the Response
  RESULT_PATTERN = /Result/
  # Additional elements to be considered a 'Result' despite not matching RESULT_PATTERN
  ACCEPTABLE_RESULTS = %w( HIT Qualification QualificationType QualificationRequest Information )

  def initialize( args )
    missing_parameters = REQUIRED_PARAMETERS - args.keys
    raise "Missing paramters: #{missing_parameters.join(',')}" unless missing_parameters.empty?
    @relay = args[:Relay]
  end

  def dispatch(method, *args)
    try = 0
    begin
      try += 1
      log "Dispatching call to #{method} (try #{try})"
      response = @relay.send(method,*args)
      validateResponse( response )
      return response
    rescue Exception => error
      case handleError( error,method )
      when :RetryWithBackoff
        retry if doBackoff( try )
      when :RetryImmediate
        retry if canRetry( try )
      when :Ignore
        return :IgnoredError => error
      when :Unknown
        raise Util::UnknownResultException.new( error, method, args )
      when :Fail
        raise error
      else
        raise "Unknown error handling method: #{handleError( error,method )}"
      end
      raise error
    end
  end

  def methodRetryable( method )
    RETRY_PRE.each do |pre|
      return true if method.to_s =~ /^#{pre}/i
    end
    return false
  end

  def handleError( error, method )
    log "Handling error: #{error.inspect}"
    case error.class.to_s
    when 'Timeout::Error','SOAP::HTTPStreamError'
      if methodRetryable( method )
        return :RetryImmediate
      else
        return :Unknown
      end
    when 'SOAP::FaultError'
      case error.faultcode.data
      when "aws:Server.ServiceUnavailable"
        return :RetryWithBackoff
      else
        return :Unknown
      end
    when 'Amazon::WebServices::Util::ValidationException'
      return :Fail
    when 'RuntimeError'
      case error.message
      when 'Throttled'
        return :RetryWithBackoff
      else
        return :RetryImmediate
      end
    else
      return :Unknown
    end
  end

  def canRetry( try )
    try <= MAX_RETRY
  end

  def doBackoff( try )
    return false unless canRetry(try)
    delay = BACKOFF_INITIAL * ( BACKOFF_BASE ** try )
    sleep delay
    return true
  end

  def isResultTag( tag )
    tag.to_s =~ RESULT_PATTERN or ACCEPTABLE_RESULTS.include?( tag.to_s )
  end

  def validateResponse(response)
    log "Validating response: #{response.inspect}"
    raise 'Throttled' if response[:Errors] and response[:Errors][:Error] and response[:Errors][:Error][:Code] == "ServiceUnavailable"
    raise Util::ValidationException.new(response) unless response[:OperationRequest][:Errors].nil?
    resultTags = response.keys.find_all {|r| isResultTag( r ) }
    raise Util::ValidationException.new(response, "Didn't get back an acceptable result tag (got back #{response.keys.join(',')})") if resultTags.empty?
    resultTags.each do |resultTag|
      log "using result tag <#{resultTag}>"
      result = response[resultTag]
      raise Util::ValidationException.new(response) unless result[:Request][:Errors].nil?
    end
    response
  end

end # MechanicalTurkErrorHandler

end # Amazon::WebServices::MTurk
end # Amazon::WebServices
end # Amazon
