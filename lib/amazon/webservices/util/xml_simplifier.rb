# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'rexml/document'

module Amazon
module WebServices
module Util

class XMLSimplifier

  # simplify(xml) -- convert an xml document into a simple nested hash
  def self.simplify(xml)
    case xml.class.to_s
    when 'REXML::Text'
      {}
    when 'REXML::Document'
      xml.root.children.inject({}) {|data,child| self.merge( data, simplify(child) ) }
    when 'REXML::Element'
      if xml.children.size > 1 || xml.text.nil?
        value = xml.children.inject({}) { |data,child| self.merge( data, simplify(child) ) }
        { xml.name.to_sym => value }
      else
        str = xml.text
        value = case str
        when /^(\d+)-(\d+)-(\d+)T(\d+):(\d+):(\d+)Z$/
          Time.gm($1,$2,$3,$4,$5,$6)
        when /^\d+$/
          if str.to_i.to_s == str
            str.to_i
          else
            str
          end
        when /^\d+\.\d+$/
          str.to_f
        else
          str
        end
        { xml.name.to_sym => value }
      end
    else
      raise "XMLSimplifier -- failed to simplify: #{xml.inspect}"
    end
  end

  def self.merge(hash1, hash2)
    hash2.each_key { |key|
      if hash1[key]
        hash1[key] = [hash1[key], hash2[key]].flatten
      else
        hash1[key] = hash2[key]
      end
    }
    hash1
  end

end # Amazon::WebServices::Util::XMLSimplifier

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
