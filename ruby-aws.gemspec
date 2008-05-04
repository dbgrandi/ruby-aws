Gem::Specification.new do |s|
  s.name = %q{ruby-aws}
  s.version = "1.2.0"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["David J Parrott"]
  s.date = %q{2008-05-04}
  s.default_executable = %q{ruby-aws}
  s.description = %q{Libraries for Amazon Web Services (ruby-aws) is a set of libraries and tools designed to make it easier for you to build solutions leveraging Amazon Web Services like Amazon Mechanical Turk.  The goals of the libraries are:  * To abstract you from the "muck" of using web services * To simplify using the various Amazon Web Service APIs * To allow you to focus more on solving the business problem and less on managing technical details}
  s.email = %q{ruby-aws-develop@rubyforge.org}
  s.executables = ["ruby-aws"]
  s.extra_rdoc_files = ["History.txt", "LICENSE.txt", "Manifest.txt", "NOTICE.txt", "README.txt"]
  s.files = ["History.txt", "LICENSE.txt", "Manifest.txt", "NOTICE.txt", "README.txt", "Rakefile", "bin/ruby-aws", "lib/amazon/util.rb", "lib/amazon/util/binder.rb", "lib/amazon/util/data_reader.rb", "lib/amazon/util/filter_chain.rb", "lib/amazon/util/hash_nesting.rb", "lib/amazon/util/lazy_results.rb", "lib/amazon/util/logging.rb", "lib/amazon/util/paginated_iterator.rb", "lib/amazon/util/proactive_results.rb", "lib/amazon/util/threadpool.rb", "lib/amazon/util/user_data_store.rb", "lib/amazon/webservices/mechanical_turk.rb", "lib/amazon/webservices/mechanical_turk_requester.rb", "lib/amazon/webservices/mturk/mechanical_turk_error_handler.rb", "lib/amazon/webservices/mturk/question_generator.rb", "lib/amazon/webservices/util/amazon_authentication_relay.rb", "lib/amazon/webservices/util/command_line.rb", "lib/amazon/webservices/util/convenience_wrapper.rb", "lib/amazon/webservices/util/filter_proxy.rb", "lib/amazon/webservices/util/mock_transport.rb", "lib/amazon/webservices/util/request_signer.rb", "lib/amazon/webservices/util/rest_transport.rb", "lib/amazon/webservices/util/soap_simplifier.rb", "lib/amazon/webservices/util/soap_transport.rb", "lib/amazon/webservices/util/soap_transport_header_handler.rb", "lib/amazon/webservices/util/unknown_result_exception.rb", "lib/amazon/webservices/util/validation_exception.rb", "lib/amazon/webservices/util/xml_simplifier.rb", "lib/ruby-aws.rb", "lib/ruby-aws/version.rb", "samples/mturk/best_image/BestImage.rb", "samples/mturk/best_image/best_image.properties", "samples/mturk/best_image/best_image.question", "samples/mturk/blank_slate/BlankSlate.rb", "samples/mturk/blank_slate/BlankSlate_multithreaded.rb", "samples/mturk/helloworld/MTurkHelloWorld.rb", "samples/mturk/helloworld/mturk.yml", "samples/mturk/reviewer/Reviewer.rb", "samples/mturk/reviewer/mturk.yml", "samples/mturk/simple_survey/SimpleSurvey.rb", "samples/mturk/simple_survey/simple_survey.question", "samples/mturk/site_category/SiteCategory.rb", "samples/mturk/site_category/externalpage.htm", "samples/mturk/site_category/site_category.input", "samples/mturk/site_category/site_category.properties", "samples/mturk/site_category/site_category.question", "test/mturk/test_changehittypeofhit.rb", "test/mturk/test_error_handler.rb", "test/mturk/test_mechanical_turk_requester.rb", "test/mturk/test_mock_mechanical_turk_requester.rb", "test/test_ruby-aws.rb", "test/unit/test_binder.rb", "test/unit/test_data_reader.rb", "test/unit/test_exceptions.rb", "test/unit/test_hash_nesting.rb", "test/unit/test_lazy_results.rb", "test/unit/test_mock_transport.rb", "test/unit/test_paginated_iterator.rb", "test/unit/test_proactive_results.rb", "test/unit/test_question_generator.rb", "test/unit/test_threadpool.rb", "test/unit/test_user_data_store.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://rubyforge.org/projects/ruby-aws/}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ruby-aws}
  s.rubygems_version = %q{0.9.5}
  s.summary = %q{Ruby libraries for working with Amazon Web Services ( Mechanical Turk )}
  s.test_files = ["test/mturk/test_changehittypeofhit.rb", "test/mturk/test_error_handler.rb", "test/mturk/test_mechanical_turk_requester.rb", "test/mturk/test_mock_mechanical_turk_requester.rb", "test/test_ruby-aws.rb", "test/unit/test_binder.rb", "test/unit/test_data_reader.rb", "test/unit/test_exceptions.rb", "test/unit/test_hash_nesting.rb", "test/unit/test_lazy_results.rb", "test/unit/test_mock_transport.rb", "test/unit/test_paginated_iterator.rb", "test/unit/test_proactive_results.rb", "test/unit/test_question_generator.rb", "test/unit/test_threadpool.rb", "test/unit/test_user_data_store.rb"]

  s.add_dependency(%q<highline>, [">= 1.2.7"])
  s.add_dependency(%q<hoe>, [">= 1.5.1"])
end
