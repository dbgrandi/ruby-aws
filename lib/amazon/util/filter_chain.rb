# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module Util

# A class for managing around style interceptors,
# which can be used to implement a decorator design pattern.
class FilterChain

  class Filter
   
    attr_reader :name, :filter_params, :filter_block
 
    def initialize( name, filter_params, filter_block )
      @name = name
      @filter_params = filter_params
      @filter_block = filter_block
    end

    def execute( chain, block_params )
      @filter_block.call( chain, block_params, *@filter_params )
    end

  end

  attr_reader :filters

  def initialize()
    @filters = []
  end

  def execute( *block_params, &block )
    if @filters.size == 0
      block.call( *block_params )
    else
      create_chain( @filters, 0, block, block_params ).call
    end 
  end

  def add( name=nil, *filter_params, &filter_block )
    add_filter( Filter.new( name, filter_params, filter_block ) )
  end

  def add_filter( filter )
    if !filter.name.nil?
      @filters.each_with_index { |existing_filter,i|
        if filter.name == existing_filter.name
          @filters[i] = filter
          return
        end
      }
    end
    @filters << filter
  end

  def remove( name )
    @filters.delete_if { |filter| name == filter.name }
  end

  def remove_all()
    @filters.clear
  end

  private

  def create_chain( filters, pos, block, block_params )
    if pos >= filters.size
      return proc{ block.call( *block_params ) }
    else
      chain = create_chain( filters, pos+1, block, block_params ) 
      return proc { filters[pos].execute( chain, block_params ) }
    end
  end

end

end # Amazon::Util
end # Amazon
