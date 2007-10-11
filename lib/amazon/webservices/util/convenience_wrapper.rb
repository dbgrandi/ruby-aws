# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'amazon/util'

module Amazon
module WebServices
module Util

class ConvenienceWrapper
  include Amazon::Util::Logging

  REQUIRED_PARAMETERS = [:ServiceClass]

  def initialize(args)
    missing_parameters = REQUIRED_PARAMETERS - args.keys
    raise "Missing paramters: #{missing_parameters.join(',')}" unless missing_parameters.empty?
    @service = args[:ServiceClass].new( args )
  end

  def callService( method, *args )
    @service.send( method, *args )
  end

  def method_missing( method, *args )
    if @service.respond_to? method
      callService( method, *args )
    else
      callService( ConvenienceWrapper.real_method( method ), *args )
    end
  end

  def self.serviceCall( method, responseTag, defaultArgs={} )
    method = method.to_s
    name = ( method[0..0].downcase + method[1..-1] ).to_sym
    rawName = ( name.to_s + "Raw" ).to_sym
    method = real_method( method )

    raise 'Stop redifining service methods!' if self.instance_methods.include? name.to_s

    define_method( rawName ) do |args|
      log "Sending service request '#{name}' with args: #{args.inspect}"
      result = callService( method, args )
      return result[responseTag]
    end

    define_method( name ) do |*params|
      userArgs = params[0] || {}
      args = defaultArgs.merge( userArgs )
      self.send rawName, args
    end
  end

  def self.paginate( method, elementTag, pageSize=25 )
    method = method.to_s
    all_name = ( method[0..0].downcase + method[1..-1] + "All" ).to_sym
    iterator_name = ( method[0..0].downcase + method[1..-1] + "Iterator" ).to_sym
    proactive_name = ( method[0..0].downcase + method[1..-1] + "AllProactive" ).to_sym
    method = ( method[0..0].downcase + method[1..-1] ).to_sym

    raise 'Stop redifining service methods!' if self.instance_methods.include? name.to_s

    processors = { all_name => Amazon::Util::LazyResults,
                   iterator_name => Amazon::Util::PaginatedIterator,
                   proactive_name => Amazon::Util::ProactiveResults }

    processors.each do |name,processor|
      define_method( name ) do |*params|
        userArgs = params[0] || {}
        args = {:PageSize => pageSize}.merge( userArgs ) # allow user to override page size
        return processor.new do |pageNumber|
          pageArgs = args.merge({:PageNumber => pageNumber}) # don't allow override of page number
          res = self.send( method, pageArgs)[elementTag]
          res.nil? ? nil : [res].flatten
        end
      end
    end

  end

  def self.real_method( method )
    method = method.to_s
    method = ( method[0..0].upcase + method[1..-1] ).to_sym
  end

end # ConvenienceWrapper

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
