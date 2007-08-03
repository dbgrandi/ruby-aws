#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

begin ; require 'rubygems' ; rescue LoadError ; end

# The BlankSlate sample application disposes all of your HITs on sandbox

require 'ruby-aws'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Sandbox

def forceExpire(id)
  print "Ensuring HIT #{id} is expired: "
  begin
    @mturk.forceExpireHIT( :HITId => id )
  rescue => e
    raise e unless e.message == 'AWS.MechanicalTurk.InvalidHITState'
  end
  puts "OK"
end

def dispose(id)
  print "Disposing HIT #{id}: "
  @mturk.disposeHIT( :HITId => id )
  puts "OK"
end

def purge
  hit_ids = @mturk.searchHITsAll.collect {|hit| hit[:HITId] }
  puts "Found #{hit_ids.size} HITs"

  return false if hit_ids.size == 0

  hit_ids.each do |id|
    begin
      forceExpire id
      dispose id
    rescue Exception => e
      puts e.inspect
    end
  end
  
  return true
end

while purge
  puts 'Ensuring there are no more hits...'
end

puts 'You now have a blank slate'
