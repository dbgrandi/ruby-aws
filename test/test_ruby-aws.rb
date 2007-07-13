# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit'
require 'ruby-aws'

class TestRubyAWS < Test::Unit::TestCase

  def testVersion
    assert( RubyAWS::VERSION =~ /^\d+\.\d+\.\d+$/ , "RubyAWS::VERSION is incorrectly formatted")
  end

  def testAgent
    assert( RubyAWS.agent =~ /^ruby-aws\/\d+\.\d+\.\d+$/ )
    assert( RubyAWS.agent('Tester') =~ /^ruby-aws\/\d+\.\d+\.\d+ Tester$/ )
  end

end

