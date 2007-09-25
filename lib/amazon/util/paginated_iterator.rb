# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module Util

# PaginatedIterator provides an iterator interface to a paginated
# dataset, buffering the current page. It can be used to stream
# large result sets which would not fit into memory or only need
# to be processed in a single pass.
class PaginatedIterator

  # feeder should be a block that accepts a pagenumber and 
  # returns an array containing the corresponding page
  # worth of results. It should return an empty array when
  # there are no more results in the dataset.
  def initialize( &feeder )
    @feeder = feeder
    restart
  end

  # resets the iterator to start pulling from the first page
  def restart
    @buffer = []
    @page = 1
    @done = false
  end

  # returns the next item, or nil if there are no more items
  def next
    fetchpage if @buffer.empty?
    @buffer.shift
  end

  # checks if we have another item available
  def hasNext
    fetchpage if @buffer.empty?
    return !@buffer.empty?
  end

  # iterates over the remaining items
  def each( &block ) # :yields: item
    until @done
      item = self.next
      yield item unless item.nil?
    end
  end

  attr_reader :done

  private

  def fetchpage
    return [] if @done
    res = @feeder.call @page
    res = [res].flatten - [nil]
    if res.nil? or res.empty?
      @done = true
      return []
    else
      @page += 1
      @buffer += res
      return res
    end
  end

end # PaginatedIterator

end # Amazon::Util
end # Amazon
