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

def approveRemainingAssignments(id)
  print "Approving remaining assignments for HIT #{id}: "
  count = 0
  @mturk.getAssignmentsForHITAll( :HITId => id ).each do |assignment|
    @mturk.approveAssignment :AssignmentId => assignment[:AssignmentId] if assignment[:AssignmentStatus] == 'Submitted'
    count += 1
  end
  puts "OK (Approved #{count})"
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
      approveRemainingAssignments id
      dispose id
    rescue Exception => e
      raise e if e.is_a? Interrupt
      puts e.inspect
    end
  end
  
  return true
end

while purge
  puts 'Ensuring there are no more hits...'
end

puts 'You now have a blank slate'
