# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'logger'

module Amazon
module Util
module Logging

  @@AmazonLogger = nil

  def set_log( filename )
    @@AmazonLogger = Logger.new filename
  end

  def log( str )
    set_log 'ruby-aws.log' if @@AmazonLogger.nil?
    @@AmazonLogger.debug str
  end

end
end
end
