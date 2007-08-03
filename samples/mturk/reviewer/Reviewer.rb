#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

begin ; require 'rubygems' ; rescue LoadError ; end

# The Reviewer sample application will retrieve the completed assignments for a given HIT,
# output the results and approve the assignment.
#
# mturk.yml is used to configure default settings ( must be in the same directory as Reviewer.rb )
# You will need to have the HIT ID of an existing HIT that has been accepted, completed and
# submitted by a worker.
# Or you can use the .success file generated from bulk loading several HITs (i.e. Site Category sample application).
#
# The following concepts are covered:
# - Retrieve results for a HIT
# - Output results for several HITs to a file
# - Approve assignments

require 'ruby-aws'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Config => File.join( File.dirname(__FILE__), 'mturk.yml' )

# Prints the submitted results of HITs when provided with a .success file.
# successFile:: The .success file containing the HIT ID and HIT Type ID
# outputFile:: The output file to write the submitted results to
def printResults( successFile,  outputFile)

  # Loads the .success file containing the HIT IDs and HIT Type IDs of HITs to be retrieved.
  success = Amazon::Util::DataReader.load( successFile, :Tabular )

  # Retrieves the submitted results of the specified HITs from Mechanical Turk
  results = @mturk.getHITResults(success)

  # parse answers to they're easier to digest
  results.each { |assignment| assignment[:Answers] = @mturk.simplifyAnswer( assignment[:Answer] ) }

  # Writes the submitted results to the defined output file.
  # The output file is a tab delimited file containing all relevant details
  # of the HIT and assignments.  The submitted results are included as the last set of fields
  # and are represented as tab separated question/answer pairs
  Amazon::Util::DataReader.save( outputFile, results, :Tabular )
  puts "Results have been written to: #{outputFile}"

end

# Prints the submitted results of a HIT when provided with a HIT ID.
# hitId:: The HIT ID of the HIT to be retrieved.
def reviewAnswers( hitId )
  assignments = @mturk.getAssignmentsForHITAll( :HITId => hitId, :AssignmentStatus => 'Submitted')

  puts "--[Reviewing HITs]----------"
  puts "  HIT Id: #{hitId}"

  assignments.each do |assignment|

    # By default, answers are specified in XML
    answerXML = assignment[:Answer]

    # Calling a convenience method that will parse the answer XML and extract out the question/answer pairs.
    answers = @mturk.simplifyAnswer( answerXML )

    answers.each do |id,answer|
      assignmentId = assignment[:AssignmentId]
      puts "Got an answer \"#{answer}\" for \"#{id}\" from worker #{assignment[:WorkerId]}"
    end

    # Approving the assignment
    @mturk.approveAssignment(:AssignmentId => assignment[:AssignmentId], :RequesterFeedback => "Well Done!")
    puts "Approved."

  end
  puts "--[End Reviewing HITs]----------"
end

require 'optparse'
hitsToReview = []
opts = OptionParser.new
opts.on( '--review HITId', 'Review Answers for a single HIT ( can be specified multiple times)') {|hit| hitsToReview << hit ; @review = true }
opts.on( '--results', 'Print Results using input and output files') { @getResults = true }
opts.on( '--input FILE', 'Input File to get results') {|file| @inputFile = file }
opts.on( '--output FILE', 'Output File to save results') {|file| @outputFile = file }

begin
  opts.parse ARGV
  raise "Please, either --review or --results, not both" if @review && @getResults
  raise "Pick something to do ( either --review or --results )" unless @review || @getResults
  if @getResults
    raise "missing input file" unless @inputFile
    raise "missing output file" unless @outputFile
    raise "input file does not exist: #{@inputFile}" unless File.exists? @inputFile
  end
rescue => e
  puts e.message
  puts opts.to_s
  exit
end

if @getResults
  printResults( @inputFile, @outputFile )
elsif @review
  hitsToReview.each {|h| reviewAnswers(h) }
end
