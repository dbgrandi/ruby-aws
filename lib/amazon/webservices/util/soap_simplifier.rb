# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

module Amazon
module WebServices
module Util

class SOAPSimplifier

  # simplify(item) -- convert a soap object into a simple nested hash
  def self.simplify(item)
    case item.class.to_s
    when 'SOAP::Mapping::Object'
      simple = {}
      item.__xmlattr.each {|name,at| simple["*#{name}*"] = simplify(at)}
      item.__xmlele.each { |element|
        # element consists of a QName and a payload
        name = element[0].name
        payload = simplify(element[1])
        simple[name.to_sym] = payload
      }
      simple
    when 'Array'
      item.collect {|i| simplify(i) }
    else
      str = item.to_s
      case str
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
    end
  end

end # Amazon::WebServices::Util::SoapSimplifier

end # Amazon::WebServices::Util
end # Amazon::WebServices
end # Amazon
