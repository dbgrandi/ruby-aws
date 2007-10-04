# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'ruby-aws'
require 'amazon/util/logging'
require 'amazon/webservices/util/amazon_authentication_relay'
require 'amazon/webservices/mturk/mechanical_turk_error_handler'
require 'amazon/webservices/util/validation_exception'
require 'amazon/webservices/util/rest_transport'
require 'amazon/webservices/util/soap_transport'

module Amazon
module WebServices

class MechanicalTurk
  include Amazon::Util::Logging

  SOFTWARE_NAME = 'MTurkRubySDK'

  SANDBOX = 'mechanicalturk.sandbox.amazonaws.com'
  PROD = 'mechanicalturk.amazonaws.com'

  # By default, MechanicalTurk will operate on the MechanicalTurk Sandbox.  To run against the main site, pass +:Host => :Production+ into the constructor.
  def initialize(args={})
    name = args[:Name] || 'AWSMechanicalTurkRequester'
    software = args.has_key?(:SoftwareName) ? "#{SOFTWARE_NAME}, #{args[:SoftwareName]}" : "#{SOFTWARE_NAME}"
    @host = case args[:Host].to_s
      when /^Prod/i
        PROD
      when /^Sandbox/i,""
        SANDBOX
      else
        args[:Host].to_s
      end
    newargs = args.merge( :Name => name, :SoftwareName => software, :Host => @host )
    transport = case args[:Transport]
      when :SOAP,/^SOAP/i
        getSOAPTransport(newargs)
      when :REST,/^REST/i
        getRESTTransport(newargs)
      else
        require 'amazon/webservices/util/soap_transport.rb'
        allowOverride( 'Transport', args[:Transport], newargs ) { |a|
          if Util::RESTTransport.canPost?
            getRESTTransport(newargs)
          elsif Util::SOAPTransport.canSOAP?
            getSOAPTransport(newargs)
          else
            getRESTTransport(newargs)
          end
        }
      end
    newargs.merge!( :Transport => transport )
    log "Generating relay with following args: #{newargs.inspect}"
    relay = allowOverride('Relay',args[:Relay],newargs) { |a| Amazon::WebServices::Util::AmazonAuthenticationRelay.new(a) }
    newargs.merge!( :Relay => relay )
    log "Generating error handler with the following args: #{newargs.inspect}"
    @errorHandler = allowOverride('ErrorHandler',args[:ErrorHandler],newargs) { |a| Amazon::WebServices::MTurk::MechanicalTurkErrorHandler.new(a) }
  end

  attr_accessor :host

  def method_missing(method,*args)
    log "Sending request: #{method} #{args.inspect}"
    @errorHandler.dispatch(method,*args)
  end

  private

  def allowOverride(name,override,args,&default)
    newargs = args.merge( :DefaultOverride => default )
    case override
    when nil
        yield( args )
    when String,Symbol,Array,Hash,Integer
      raise "Invalid #{name}: #{override.inspect}"
    when Class
      override.new( newargs )
    else
      override.configure( newargs ) if override.respond_to? :configure
      override
    end
  end

  def getRESTTransport(args)
    endpoint = findRestEndpoint( args[:Name], args[:Host] )
    require 'amazon/webservices/util/rest_transport.rb'
    @transport = Amazon::WebServices::Util::RESTTransport.new( args.merge( :Endpoint => endpoint ) )
  end

  def getSOAPTransport(args)
    wsdl = findWSDL( args[:Name], args[:Host], args[:Version] )
    endpoint = findSOAPEndpoint( args[:Name], args[:Host] )
    require 'amazon/webservices/util/soap_transport.rb'
    Amazon::WebServices::Util::SOAPTransport.new( args.merge( :Wsdl => wsdl, :Endpoint => endpoint ) )
  end

  def findWSDL( name, host, version )
    if version.nil?
      "http://#{host}/AWSMechanicalTurk/#{name}.wsdl"
    else
      "http://#{host}/AWSMechanicalTurk/#{version}/#{name}.wsdl"
    end
  end

  def findSOAPEndpoint( name, host )
    "http://#{host}/onca/soap?Service=#{name}"
  end

  def findRestEndpoint( name, host )
    "http://#{host}/?Service=#{name}"
  end

end # MTurk

end # Amazon::WebServices
end # Amazon
