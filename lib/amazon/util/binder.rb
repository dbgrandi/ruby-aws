# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'erb'

module Amazon
module Util

# Simple class for holding eval information
# useful for feeding to ERB templates and the like
class Binder

  def initialize(initial={},&block) # :yields: self 
    initial.each {|k,v| set(k,v) }
    yield self unless block.nil?
  end

  def merge(hash)
    hash.each {|k,v| set(k,v) }
  end

  def set(k,v)
    self.instance_variable_set "@#{k.to_s}", "#{v.to_s}"
  end

  def bind
    binding
  end
  
  # Helper method to simplify ERB evaluation
  def erb_eval( template )
    buffer = ""
    c = ERB::Compiler.new("")
    c.put_cmd = "buffer <<" if c.respond_to? :put_cmd=
    c.insert_cmd = "buffer <<" if c.respond_to? :insert_cmd=
    compiled = c.compile template
    eval compiled
    return buffer
  end

end # Binder

end # Amazon::Util
end # Amazon
