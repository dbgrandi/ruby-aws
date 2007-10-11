Libraries For Amazon Web Services (ruby-aws)
* http://www.rubyforge.org/projects/ruby-aws/

== Description

Libraries for Amazon Web Services (ruby-aws) is a set of libraries and tools
designed to make it easier for you to build solutions leveraging Amazon Web
Services like Amazon Mechanical Turk.  The goals of the libraries are:

* To abstract you from the "muck" of using web services
* To simplify using the various Amazon Web Service APIs
* To allow you to focus more on solving the business problem
  and less on managing technical details

== Usage

  require 'ruby-aws'
  @mturk = Amazon::WebServices::MechanicalTurkRequester.new
  puts "I have $#{@mturk.availableFunds} in Sandbox"
  @mturk_prod = Amazon::WebServices::MechanicalTurkRequester.new :Host => :Production
  puts "I have $#{@mturk_prod.availableFunds} in Production"

For more in-depth example code, check out the samples folder included in this
distribution.

== Prerequisites

To use the Libraries and successfully run the samples,
you must meet these prerequisites:

* You must have an Amazon Web Services (AWS) account. You can sign up at
  the {AWS web site}[http://aws.amazon.com].
* You must have an Amazon Mechanical Turk Requester account.
  Be sure to use the same e-mail address and password you used when creating
  your Amazon Web Services account.
  You can sign up at the {Requester web site}[http://requester.mturk.com].
* You must have Ruby 1.8.3 or later.  You can download Ruby at the following
  web site: http://www.ruby-lang.org.
* You must have RubyGems[http://rubyforge.org/projects/rubygems] installed
  and configured correctly for your Ruby installation.  Review the installation
  instructions here[http://docs.rubygems.org].

  (Note: If installing RubyGems for the first time, you may need to restart your console 
  to pick up environment changes.  To execute code that is dependent on Ruby Gems, the 
  command to execute is: "ruby -rubygems program_that_uses_gems".  The "-rubygems" 
  command line parameter should be a default parameter that is always included.  To do this,
  Ruby can utilize the "RUBYOPT" environment label that should be set to "RUBYOPT=-rubygems".
  Please refer to documentation specific to your OS on defining environment labels.)

== Installation

1. Execute the following command:
      gem install ruby-aws
      
   (Note: Some Unix-based systems may require root access to install Ruby libraries.  You
   may need to execute the above command as the following:
      sudo gem install ruby-aws
   and enter in the password to successfully install the Gem)

2. Installation of the ruby-aws gem will prompt to install the following dependent gems 
   if not already installed:
   * Hoe[http://seattlerb.rubyforge.org/hoe]
   * Highline[http://rubyforge.org/projects/highline]

3. (Optional) Download and expand the corresponding tarball/zip file from the {project
   homepage}[http://rubyforge.org/projects/ruby-aws] to an installation directory.  This will
   provide you access to the source files, test files and sample code.

4. Configure the Libraries to use your Amazon Web Services authentication credentials by
   executing the following command:
     ruby-aws

5. Verify your installation by running the automated tests by executing the following
   command in the installation path:
     rake test

== Running Sample Applications

1. Navigate to the samples\mturk directory of the installation path.
2. Run the various samples

== Comments, Questions or Feedback

If you have any comments, questions, or feedback concerning the Libraries for
Amazon Web Services, please visit our {Rubyforge project page}[http://rubyforge.org/projects/ruby-aws].

If you have any comments, questions, or feedback concerning the Mechanical
Turk service in general, please visit the {Amazon Mechanical Turk discussion
forums}[http://developer.amazonwebservices.com/connect/forum.jspa?forumID=11]

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
