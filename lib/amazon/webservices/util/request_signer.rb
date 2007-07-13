# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'base64'
require 'digest/sha1'

module Amazon
module WebServices
module Util

module RequestSigner

  def RequestSigner.sign(service,method,time,key)
    msg = "#{service}#{method}#{time}"
    return hmac_sha1( key, msg )
  end


  private

  def RequestSigner.hmac_sha1(key, s)
    ipad = [].fill(0x36, 0, 64)
    opad = [].fill(0x5C, 0, 64)
    key = key.unpack("C*")
    key += [].fill(0, 0, 64-key.length) if key.length < 64

    inner = []
    64.times { |i| inner.push(key[i] ^ ipad[i]) }
    inner += s.unpack("C*")

    outer = []
    64.times { |i| outer.push(key[i] ^ opad[i]) }
    outer = outer.pack("c*")
    outer += Digest::SHA1.digest(inner.pack("c*"))

    return Base64::encode64(Digest::SHA1.digest(outer)).chomp
  end

end # Amazon::MTS::Util::RequestSigner
end # Amazon::MTS::Util
end # Amazon::MTS
end # Amazon
