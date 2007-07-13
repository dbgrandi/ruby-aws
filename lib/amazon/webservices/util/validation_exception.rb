# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module WebServices
module Util

class ValidationException < RuntimeError

  attr_reader :message, :description, :result

  def initialize( result, message=nil )
    @result = result

    @message = [
      message,
      get_nested_key( result, :OperationRequest, :Errors, :Error, :Code ),
      get_nested_key( result, :Request, :Errors, :Error, :Code ),
      get_nested_key( result, :Errors, :Error, :Code ),
    ].detect { |v| !v.nil? }

    @description = [
      get_nested_key( result, :OperationRequest, :Errors, :Error, :Message ),
      get_nested_key( result, :Request, :Errors, :Error, :Message ),
      get_nested_key( result, :Errors, :Error, :Message ),
    ].detect { |v| !v.nil? }

  end

  def to_s
    "ValidationException: #{message}"
  end

  private

  def get_nested_key( hash, *keys )
    return nil unless hash.kind_of?(Hash)
    result = hash
    if hash.key? keys.first
      keys.each do |key|
        return nil unless result.kind_of?(Hash)
        result = result[key]
      end
      return result
    else
      nested = hash.collect { |k,v| get_nested_key( v, *keys ) }
      return ([nested].flatten - [nil]).first
    end
  end

end

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
