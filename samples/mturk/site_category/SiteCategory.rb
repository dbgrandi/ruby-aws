#!/usr/bin/env ruby

# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

# The Site Category sample application will create 5 HITs asking workers to categorize websites into predefined categories.
#
# mturk.properties must be found in the current file path.
#
# The following concepts are covered:
# - Bulk load HITs using an input file
# - File based HIT loading

require 'amazon/webservices/mechanical_turk_requester'
@mturk = Amazon::WebServices::MechanicalTurkRequester.new

# Check to see if your account has sufficient funds
def hasEnoughFunds?
  available = @mturk.availableFunds
  puts "Got account balance: %.2f" % available
  return available > 0
end

# Create the website category HITs.
def createSiteCategoryHITs

  # Defining the locations of the input files
  rootDir = File.dirname $0
  inputFile = rootDir + "/site_category.input"
  propertiesFile = rootDir + "/site_category.properties"
  questionFile = rootDir + "/site_category.question"

  # Loading the input file.  The input file is a tab delimited file where the first row
  # defines the fields/variables and the remaining rows contain the values for each HIT.
  # Each row represents a unique HIT.  ERB is used to merge the values into the Question template.
  input = Amazon::Util::DataReader.load( inputFile, :Tabular )

  # Loading the question (QAP) file
  question = File.read( questionFile )

  # Loading the HIT properties file.  The properties file defines two system qualifications that will
  # be used for the HIT.  The properties file can also be a Velocity template.  Currently, only
  # the "annotation" field is allowed to be a Velocity template variable.  This allows the developer
  # to "tie in" the input value to the results.
  props = Amazon::Util::DataReader.load( propertiesFile, :Properties )

  hits = [];

  # Create multiple HITs using the input, properties, and question files

  puts "--[Loading HITs]----------"
  startTime = Time.now
  puts "  Start time: #{startTime}"

  # The simpliest way to bulk load a large number of HITs where all details are defined in files.
  # This method returns a hash with two arrays:
  # - :Created is an array of successfully created HITs
  # - :Failed is an array of lines we failed to create HITs with
  hits = @mturk.createHITs(props, question, input);

  puts "--[End Loading HITs]----------"
  endTime = Time.now
  puts "  End time: #{endTime}"
  puts "--[Done Loading HITs]----------"
  puts "  Total load time: #{ endTime - startTime } seconds."


  # We'll save the results to hits.success and hits.failure
  Amazon::Util::DataReader.save( rootDir + "/hits.success", hits[:Created], :Tabular )
  Amazon::Util::DataReader.save( rootDir + "/hits.failure", hits[:Failed], :Tabular )
  # The .success file can be used in subsequent operations to retrieve the results that workers submitted.

end

    
createSiteCategoryHITs if hasEnoughFunds?
