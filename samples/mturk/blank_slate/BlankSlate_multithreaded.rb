#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

begin ; require 'rubygems' ; rescue LoadError ; end

# The BlankSlate sample application disposes all of your HITs on sandbox

require 'ruby-aws'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Sandbox
require 'amazon/util/threadpool'

def forceExpire(id)
  @mturk.forceExpireHIT( :HITId => id )
rescue
end

def approveRemainingAssignments(id)
  @mturk.getAssignmentsForHITAll( :HITId => id ).each do |assignment|
    begin
      @mturk.approveAssignment :AssignmentId => assignment[:AssignmentId] if assignment[:AssignmentStatus] == 'Submitted'
    rescue
    end
  end
end

def dispose(id)
  @mturk.disposeHIT( :HITId => id )
end

def purge
  puts "*** starting purge ***"
  hit_ids = @mturk.searchHITsAllProactive.collect {|hit| hit[:HITId] }
  puts "Found #{hit_ids.size} HITs"

  return false if hit_ids.size == 0

  threadpool = Amazon::Util::ThreadPool.new(12)

  puts "*** loading work ***"
  hit_ids.each do |hid|
    threadpool.addWork(hid) do |id|
      begin
        puts "starting #{id}"
        forceExpire id
        approveRemainingAssignments id
        dispose id
        puts "cleared #{id}"
      rescue Exception => e
        raise e if e.is_a? Interrupt
        puts e.inspect
      end
    end
  end
  puts "*** finished adding to queue ***"

  threadpool.finish
  
  return true
end

while purge
  puts 'Ensuring there are no more hits...'
end

puts 'You now have a blank slate'
