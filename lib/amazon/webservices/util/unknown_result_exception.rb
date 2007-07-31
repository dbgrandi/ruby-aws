# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module WebServices
module Util

# This exception is thrown when we don't know if a service call succeeded or not
class UnknownResultException < RuntimeError

  attr_reader :method, :args, :exception

  def initialize( exception, method, args={} )
    @method = method
    @args = args
    @exception = exception
  end

  def to_s
    "UnknownResultException: got #{@exception} calling #{@method}"
  end

end

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
