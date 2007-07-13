# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module Util
  
module HashNesting
  
  def nest
    result = {}.extend HashNesting
    primaryKeys.each { |key| traverse_nest( "#{key}", self[key] ) { |k,v| result[k] = v } }
    result
  end
  
  def nest!
    keys = primaryKeys
    tmp = self.dup
    self.keys.each { |k| self.delete k}
    keys.each { |key| traverse_nest( "#{key}", tmp[key] ) { |k,v| self[k] = v} }
    self
  end
  
  def unnest
    result = {}.extend HashNesting
    for key in primaryKeys
      true_keys = key.to_s.split('.')
      resolve_nesting( result, self[key], *true_keys)
    end
    result
  end
  
  def unnest!
    for key in primaryKeys
      true_keys = key.to_s.split('.')
      value = self[key]
      self.delete key
      resolve_nesting( self, value, *true_keys)
    end
    self
  end

  private
  
  # if hash has both string and symbol keys, symbol wins
  def primaryKeys
    sym_keys = []
    str_keys = []
    self.keys.each { |k|
      case k
      when Symbol
        sym_keys << k
      when String
        str_keys << k
      else
        str_keys << k
      end
    }
    str_keys.delete_if {|k| sym_keys.member? k.to_s.to_sym }
    sym_keys + str_keys
  end
  
  def resolve_nesting( dest, data, *keys )
    return data if keys.empty?
    dest ||= {}
    key = keys.shift.to_sym
    if keys.first.to_i.to_s == keys.first
      # array
      index = keys.shift.to_i - 1
      raise "illegal index: #{keys.join '.'}  index must be >= 1" if index < 0
      dest[key] ||= []
      dest[key][index] = resolve_nesting( dest[key][index], data, *keys )
    else
      # hash
      dest[key] = resolve_nesting( dest[key], data, *keys )
    end
    dest
  end
  
  def traverse_nest( namespace, data, &block )
    case data.class.to_s
    when 'Array'
      data.each_with_index { |v,i| traverse_nest( "#{namespace}.#{i+1}", v, &block ) }
    when 'Hash'
      data.each { |k,v| traverse_nest( "#{namespace}.#{k}", v, &block ) }
    else
      yield namespace, data.to_s
    end
  end
  
end # HashNesting

end # Amazon::Util
end # Amazon
