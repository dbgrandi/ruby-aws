# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'amazon/util/filter_chain'

module Amazon
module WebServices
module Util

# Filter proxy is a class that can filter argument input before passing onto a proxy object
# == Usage
# Initialize with standard argument block, pass the class or pre-initialized object as the :FilterProxy parameter.
# All parameters will be passed along to the contructor of the passed class.
# FilterProxy exposes a FilterChain object, with all the magic which that class provides.
class FilterProxy

  attr_accessor :filter_chain
  
  def initialize(args)
    @filter_chain = Amazon::Util::FilterChain.new
  end

  def configure(args)
    @proxy = case args[:FilterProxy]
      when Class
        args[:FilterProxy].new( args )
      when nil
        raise "No FilterProxy or DefaultOverride defined!" unless args[:DefaultOverride].is_a? Proc
        args[:DefaultOverride].call( args )
      else
        args[:FilterProxy]
      end
  end
  
  def method_missing(method, *args)
    @filter_chain.execute(method, args) { |method,args|
      @proxy.send(method,*args)
    }
  end
  
end

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
