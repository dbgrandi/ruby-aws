# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'monitor'
require 'amazon/util/threadpool'

module Amazon
module Util

# ProactiveResults is not as lazy as LazyResults
# The constructor takes a block which should accept a pagenumber
# and return a page worth of results.
class ProactiveResults
  include Enumerable

  THREADPOOL_SIZE = 3

  def initialize( exception_handler=nil, &feeder )
    @feeder = feeder
    @eh = exception_handler
    @tp = nil
    self.flush
  end

  # clear the result set and start over again
  def flush
    @tp.finish unless @tp.nil?
    @tp = ThreadPool.new(THREADPOOL_SIZE, @eh)
    @done = false
    @inflight = [].extend(MonitorMixin)
    @current_page = 1
    @truth = []
    1.upto(THREADPOOL_SIZE) do |page|
      getPage(page)
    end
  end

  # iterate over entire result set, waiting for
  # threads to finish where necessary
  def each( &block ) # :yields: item
    index = 0
    while true
      if index >= @truth.size
        break if @done
        feedme
      else
        yield @truth[index]
        index += 1
      end
    end
  end

  # index into the result set. if we haven't
  # loaded enough, will wait until we have
  def []( index )
    feedme while !@done and index >= @truth.size
    return @truth[index]
  end

  # wait for the entire results set to be populated,
  # then return an array of the results
  def to_a
    feedme until @done
    return @truth.dup
  end

  def inspect # :nodoc:
    "#<Amazon::Util::ProactiveResults truth_size=#{@truth.size} pending_pages=#{@pending.size}>"
  end

  private

  def getPage(num)
    @inflight.synchronize do
      workitem = @tp.addWork(num) { |n| worker(n) }
      @inflight[num] = workitem
    end
  end

  def worker(page)
    res = []
    begin
      res = @feeder.call( page )
    ensure
      getPage( page + THREADPOOL_SIZE ) unless (res.nil? || res.empty?)
    end
  end

  def feedme
    return if @done
    item = nil
    @inflight.synchronize do
      if @inflight[@current_page].nil?
        raise "This should be the last page! #{@current_page} #{@inflight.inspect}" unless [] == ( @inflight - [nil] )
        @done = true
        return
      end
      item = @inflight[@current_page]
      @inflight[@current_page] = nil # clear out our references
      @current_page += 1
    end
    res = item.getResult
    case res
    when Array
      @truth += res
    when Exception, NilClass
      # ignore
    else
      raise "Unexpected result type: #{res.class}"
    end
  end

end

end # Amazon::Util
end # Amazon
