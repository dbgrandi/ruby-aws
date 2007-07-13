# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'soap/header/simplehandler.rb'
require 'xsd/qname.rb'

module Amazon
module WebServices
module Util

class SOAPTransportHeaderHandler < SOAP::Header::SimpleHandler

  def initialize(ns, tag, value)
    super(XSD::QName.new(ns, tag))
    @tag = tag
    @value = value
  end

  def on_simple_outbound
    @value
  end

end # SOAPTransportHeaderHandler

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
