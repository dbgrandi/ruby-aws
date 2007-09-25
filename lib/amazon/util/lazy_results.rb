# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'amazon/util/paginated_iterator'

module Amazon
module Util

# This class provides a wrapper for lazy evaluation of results.
# The constructor takes a block which should accept a pagenumber
# and return a page worth of results.
class LazyResults
  include Enumerable

  def initialize( &feeder )
    @iterator = PaginatedIterator.new( &feeder )
    flush
  end

  # clear the result set and start over again
  def flush
    @truth = []
    @iterator.restart
  end

  # iterate over entire result set, loading lazily
  def each( &block ) # :yields: item
    @truth.each {|e| yield e }
    @iterator.each {|e| @truth << e ; yield e }
  end

  # index into the array set.  if requested index has not been loaded, will load up to that index
  def []( index )
    feedme while !@iterator.done and index >= @truth.size
    return @truth[index]
  end

  # fully populate the result set and return a true array
  def to_a
    feedme until @iterator.done
    return @truth.dup
  end

  def inspect # :nodoc:
    "#<Amazon::Util::LazyResults truth_size=#{@truth.size} page=#{@page} done=#{@done}>"
  end

  private

  # fetch the next item from the iterator and stick it in @truth
  def feedme
    item = @iterator.next
    @truth << item unless item.nil?
  end

end # LazyResults

end # Amazon::Util
end # Amazon
