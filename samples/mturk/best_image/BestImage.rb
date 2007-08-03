#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

begin ; require 'rubygems' ; rescue LoadError ; end

# The Best Image sample application will create a HIT asking a worker
# to choose the best of three images, given a set of criteria.
#
# The following concepts are covered:
# - Using the <FormattedContent> functionality in QuestionForm
# - File-based QuestionForm and HIT properties HIT loading
# - Using a basic system qualification

require 'ruby-aws'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Sandbox

# Use this line instead if you want to talk to Prod
#@mturk = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Production


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

# Create the BestImage HIT
def createBestImage

  # Defining the location of the file containing the QuestionForm and the properties of the HIT
  rootDir = File.dirname $0;
  questionFile = rootDir + "/best_image.question";
  propertiesFile = rootDir + "/best_image.properties";

  # Loading configuration properties from a HIT properties file.
  # In this sample, the qualification is defined in the properties file.
  props = Amazon::Util::DataReader.load( propertiesFile, :Properties )
  props[:Reward] = { :Amount => 0.05, :CurrencyCode => 'USD'}
  # Loading the question (QuestionForm) file.
  question = File.read( questionFile )
  # no validation
  result = @mturk.createHIT( {:Question => question}.merge(props) )
  puts "Created HIT: #{result[:HITId]}"
  puts "Url: #{getHITUrl( result[:HITTypeId] )}"

  # save the HIT Id to a file so we don't lose it...
  Amazon::Util::DataReader.save( File.join( rootDir, "hits_created" ), [{:HITId => result[:HITId] }], :Tabular )
end

createBestImage if hasEnoughFunds?
