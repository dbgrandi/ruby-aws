#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

# The MTurk Hello World sample application creates a simple HIT via the Amazon Mechanical Turk SDK for Ruby.

require 'ruby-aws'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Config => File.join( File.dirname(__FILE__), 'mturk.yml' )

require 'amazon/webservices/mturk/question_generator'
include Amazon::WebServices::MTurk

def createHelloWorld
  title = "Answer a question"
  desc = "This is a HIT created by the Amazon Mechanical Turk SDK for Ruby.  Please answer the question."
  keywords = "sample, SDK, hello"
  numAssignments = 1
  rewardAmount = 0
  
  question = QuestionGenerator.build(:Basic) do |q|
    q.ask "What is the weather like right now in Seattle, WA?"
  end
  
  puts question
  
  result = @mturk.createHIT( :Title => title,
                    :Description => desc,
                    :MaxAssignments => numAssignments,
                    :Reward => { :Amount => rewardAmount, :CurrencyCode => 'USD' },
                    :Question => question,
                    :Keywords => keywords )

  puts "Created HIT: #{result[:HITId]}"
end

# Check to see if your account has sufficient funds
def hasEnoughFunds?
  available = @mturk.availableFunds
  puts "Got account balance: %.2f" % available
  return available > 0
end


createHelloWorld if hasEnoughFunds?
