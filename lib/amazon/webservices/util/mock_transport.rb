# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module WebServices
module Util

class MockTransport
  include Enumerable

  class MethodCall

    def initialize( name, args )
      @name = name
      @args = args
      @request = args[:Request][0]
    end

    attr_reader :name, :args, :request

  end

  def initialize( args={} )
    @call_buffer = []
    @index = 0
    @listener = nil
    @mock_reply = args[:MockReply] || { :MockResult => { :Mock => true, :Request => {} }, :OperationRequest => {} }
    @listener = args[:MockListener] if args[:MockListener].is_a? Proc
  end

  attr_reader :call_buffer
  attr_accessor :mock_reply

  def flush
    @call_buffer = []
    @index = 0
  end

  def next
    return nil if @index >= @call_buffer.size
    ret = @call_buffer[@index]
    @index += 1
    ret
  end

  def each(&block) # :yields: method_call
    @call_buffer[@index..-1].each { |item| yield item }
#    yield self.next until @index >= @call_buffer.size
  end

  def listen(&block) # :yields: method_call
    @listener = block
  end

  def method_missing(method,*args)
    raise "only support one parameter" unless args.size <= 1
    the_method = MethodCall.new( method, args[0] )
    @call_buffer << the_method
    listen_result = @listener.call( the_method ) unless @listener.nil?
    response = @mock_reply.dup
    response[:MockResult][:Request] = the_method.request unless response[:MockResult].nil?
    response.merge!(listen_result) if listen_result.is_a? Hash
    response
  end

end

end # Amazon::Webservices::Util
end # Amazon::Webservices
end # Amazon
