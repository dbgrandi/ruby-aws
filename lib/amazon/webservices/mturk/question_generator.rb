# Copyright:: Copyright (c) 2007 Amazon Technologies, Inc.
# License::   Apache License, Version 2.0

require 'rexml/element'

module Amazon
module WebServices
module MTurk

class QuestionGenerator

  def self.build(type=:Basic)
    question = self.new(type)
    yield question
    return question.to_xml
  end
  
  def initialize(type=:Basic)
    @overview = nil
    @questions = []
    @type = type
  end
  
  def ask(*args)
    case @type
    when :Basic
      askBasic( args.join )
    end
  end
  
  def askBasic(text)
    id = "BasicQuestion#{@questions.size+1}"
    question = REXML::Element.new 'Text'
    question.text = text
    answerSpec = "<FreeTextAnswer/>"
    @questions << { :Id => id, :Question => question.to_s, :AnswerSpec => answerSpec }
  end
  
  def to_xml
    components = [PREAMBLE]
    components << OVERVIEW % @overview unless @overview.nil?
    for question in @questions
      components << QUESTION % [ question[:Id], question[:Question], question[:AnswerSpec] ]
    end
    components << [TAIL]
    return components.join    
  end
  
  PREAMBLE = '<?xml version="1.0" encoding="UTF-8"?>'+"\n"+'<QuestionForm xmlns="http://mechanicalturk.amazonaws.com/AWSMechanicalTurkDataSchemas/2005-10-01/QuestionForm.xsd">'
  OVERVIEW = '<Overview>%s</Overview>'
  QUESTION = '<Question><QuestionIdentifier>%s</QuestionIdentifier><QuestionContent>%s</QuestionContent><AnswerSpecification>%s</AnswerSpecification></Question>'
  TAIL = '</QuestionForm>'
  
end # QuestionGenerator

end # Amazon::WebServices::MTurk
end # Amazon::WebServices
end # Amazon
