# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'test/unit/testcase'
require 'amazon/webservices/mturk/question_generator'

class TestQuestionGenerator < Test::Unit::TestCase
  include Amazon::WebServices::MTurk

  def testBuilder
    xml = QuestionGenerator.build { |gen| gen.ask "What color is the sky?" }
    assert_equal String, xml.class
    assert !xml.empty?
    assert xml =~ /What color is the sky/
  end

  def testXmlEscaping
    xml = QuestionGenerator.build{ |gen| gen.ask "Is 1 > 2 & < 7 ?" }
    assert xml =~ /<Text>(.*)<\/Text>/
    escaped_text = $1
    assert_equal "Is 1 &gt; 2 &amp; &lt; 7 ?", escaped_text
  end

  def testValidXML
    xml = QuestionGenerator.build{ |gen| gen.ask "who loves chocolate most?" }
    require 'rexml/document'
    # REXML will throw an exception if the xml is invalid / malformatted
    valid = REXML::Document.new(xml) 
  end

  def testAlternateInvocations
    myQuestion = "how many tuna fit in a can?"

    built = QuestionGenerator.build { |gen| gen.ask myQuestion }
    built_basic = QuestionGenerator.build( :Basic ) { |gen| gen.ask myQuestion }
    built_askbasic = QuestionGenerator.build { |gen| gen.askBasic myQuestion }

    defaultgen = QuestionGenerator.new
    defaultgen.ask myQuestion
    obj = defaultgen.to_xml

    defaultgen = QuestionGenerator.new
    defaultgen.askBasic myQuestion
    obj_askbasic = defaultgen.to_xml

    basicgen = QuestionGenerator.new( :Basic )
    basicgen.ask myQuestion
    obj_basic = basicgen.to_xml

    # all methods should generate the exact same string
    [built_basic,built_askbasic,obj,obj_askbasic,obj_basic].each { |comp| assert_equal built, comp }
  end

end
