# -*- ruby -*-
 
require 'rubygems'
require 'hoe'
require './lib/ruby-aws/version.rb'
 
Hoe.new('ruby-aws', RubyAWS::VERSION) do |p|
  p.rubyforge_name = 'ruby-aws'
  p.summary = 'Ruby libraries for working with Amazon Web Services ( Mechanical Turk )'
  p.email = 'ruby-aws-develop@rubyforge.org'
  p.author = 'David J Parrott'
  p.description = p.paragraphs_of('README.txt', 2..3).join("\n\n")
  p.url = "http://rubyforge.org/projects/ruby-aws/"
  p.changes = p.paragraphs_of('History.txt', 0..2).join("\n\n")
  p.extra_deps << ['highline','>= 1.2.7']
  p.need_tar = true
  p.need_zip = true
end

# vim: syntax=ruby
