Libraries For Amazon Web Services (ruby-aws)
* http://www.rubyforge.org/projects/ruby-aws/

== Description

Libraries for Amazon Web Services (ruby-aws) is a set of libraries and tools
designed to make it easier for you to build solutions leveraging Amazon Web
Services like Amazon Mechanical Turk.  The goals of the libraries are:
  
* To abstract you from the "muck" of using web services
* To simplify using the various Amazon Web Service APIs
* To allow you to focus more on solving the business problem and less on managing technical details

== Usage

  require 'ruby-aws'
  @mturk = Amazon::WebServices::MechanicalTurkRequester.new
  puts "I have $#{@mturk.availableFunds} in Sandbox"
  @mturk_prod = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Production
  puts "I have $#{@mturk.availableFunds} in Production"

For more in-depth example code, check out the samples folder included in this
distribution.

== Comments, Questions or Feedback

If you have any comments, questions, or feedback concerning the Libraries for
Amazon Web Services, please visit our Rubyforge project page:
http://rubyforge.org/projects/ruby-aws/

If you have any comments, questions, or feedback concerning the Mechanical
Turk service in general, please visit the Amazon Mechanical Turk discussion forums at:
http://developer.amazonwebservices.com/connect/forum.jspa?forumID=11

== License

Copyright (c) 2007 Amazon Technologies, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
