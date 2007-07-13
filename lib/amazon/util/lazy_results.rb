# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module Util

# This class provides a wrapper for lazy evaluation of results.
# The constructor takes a block which should accept a pagenumber
#  and return a page worth of results.
class LazyResults
  include Enumerable

  def initialize( &feeder )
    @feeder = feeder
    flush
  end
  
  # clear the result set and start over again
  def flush
    @truth = []
    @page = 1
    @done = false
  end

  # iterate over entire result set, loading lazily
  def each( &block ) # :yields: item
    @truth.each {|e| yield e }
    feedme.each {|e| yield e } while !@done
  end

  # index into the array set.  if requested index has not been loaded, will load up to that index
  def []( index )
    feedme while !@done and index >= @truth.size
    return @truth[index]
  end
  
  # fully populate the result set and return a true array
  def to_a
    feedme until @done
    return @truth.dup
  end
  
  def inspect
    "#<Amazon::Util::LazyResults truth_size=#{@truth.size} page=#{@page} done=#{@done}>"
  end

  private
  
  def feedme
    res = @feeder.call @page
    res = [res].flatten - [nil]
    if res.nil? or res.empty?
      @done = true
      return []
    else
      @page += 1
      @truth += res
      return res
    end
  end

end # LazyResults
  
end # Amazon::Util
end # Amazon
