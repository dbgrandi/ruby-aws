#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

begin ; require 'rubygems' ; rescue LoadError ; end

# The Simple Survey sample application will create a HIT asking a worker to indicate their
# political party preferences.
#
# mturk.properties must be found in the current file path.
#
# The following concepts are covered:
# - File based QuestionForm HIT loading
# - Using a locale qualification

require 'ruby-aws'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new


# Check to see if your account has sufficient funds
def hasEnoughFunds?
  available = @mturk.availableFunds
  puts "Got account balance: %.2f" % available
  return available > 0.055
end

def getHITUrl( hitTypeId )
  if @mturk.host =~ /sandbox/
    "http://workersandbox.mturk.com/mturk/preview?groupId=#{hitTypeId}" # Sandbox Url
  else
    "http://mturk.com/mturk/preview?groupId=#{hitTypeId}" # Production Url
  end
end

# Creates the simple survey.
def createSimpleSurvey
  title = "What is your political preference?"
  description = "This is a simple survey HIT created by the Amazon Mechanical Turk SDK for Ruby."
  numAssignments = 1
  reward = { :Amount => 0.05, :CurrencyCode => 'USD' }
  keywords = "sample, SDK, survey"
  assignmentDurationInSeconds = 60 * 60 # 1 hour
  autoApprovalDelayInSeconds = 60 * 60 # 1 hour
  lifetimeInSeconds = 60 * 60 # 1 hour
  requesterAnnotation = "sample#survey"

  # Defining the location of the externalized question (QuestionForm) file.
  rootDir = File.dirname $0
  questionFile = rootDir + "/simple_survey.question"
		

  # This is an example of creating a qualification.
  # This is a built-in qualification -- user must be based in the US
  qualReq = { :QualificationTypeId => Amazon::WebServices::MechanicalTurkRequester::LOCALE_QUALIFICATION_TYPE_ID,
              :Comparator => 'EqualTo',
              :LocaleValue => {:Country => 'US'}, }

  # The create HIT method takes in an array of QualificationRequirements since a HIT can have multiple qualifications.
  qualReqs = [qualReq]

  # Loading the question (QuestionForm) file
  question = File.read( questionFile )

  # Creating the HIT and loading it into Mechanical Turk
  hit = @mturk.createHIT( :Title => title,
                          :Description => description,
                          :Keywords => keywords,
                          :Question => question,
                          :Reward => reward,
                          :AssignmentDurationInSeconds => assignmentDurationInSeconds,
                          :AutoApprovalDelayInSeconds => autoApprovalDelayInSeconds,
                          :LifetimeInSeconds => lifetimeInSeconds,
                          :MaxAssignments => numAssignments,
                          :RequesterAnnotation => requesterAnnotation,
                          :QualificationRequirement => qualReqs )

  puts "Created HIT: #{hit[:HITId]}"
  puts "Url: #{getHITUrl( hit[:HITTypeId] )}"

  # Demonstrates how a HIT can be retrieved if you know its HIT ID
  hit2 = @mturk.getHIT(:HITId => hit[:HITId])

  puts "Retrieved HIT: #{hit2[:HITId]}"

  puts "Oops!  The HIT Ids shoud match: #{hit[:HITId]}, #{hit2[:HITId]}" unless hit[:HITId] == hit2[:HITId]

end

createSimpleSurvey if hasEnoughFunds?
