# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'soap/wsdlDriver'
require 'amazon/webservices/util/soap_simplifier'
require 'amazon/webservices/util/soap_transport_header_handler'

module Amazon
module WebServices
module Util

class SOAPTransport

  REQUIRED_PARAMETERS = [:Wsdl]

  def self.canSOAP?
    SOAP::Version >= "1.5.5"
  end

  def initialize( args )
    raise "SOAP version 1.5.5+ (included in Ruby 1.8.3+) required to use SOAP Transport" unless SOAPTransport::canSOAP?

    missing_parameters = REQUIRED_PARAMETERS - args.keys
    raise "Missing paramters: #{missing_parameters.join(',')}" unless missing_parameters.empty?
    @driver = SOAP::WSDLDriverFactory.new( args[:Wsdl] ).create_rpc_driver
    @driver.endpoint_url = args[:Endpoint] unless args[:Endpoint].nil?
    @driver.headerhandler << SOAPTransportHeaderHandler.new('http://amazonaws.com/header', 'X-Amazon-Software', RubyAWS::agent(args[:SoftwareName]) )
  end

  def method_missing( method, *args )
    SOAPSimplifier.simplify @driver.send( method, *args )
  end

end # SOAPTransport

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
