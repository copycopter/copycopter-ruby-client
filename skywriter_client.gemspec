# -*- encoding: utf-8 -*-

include_files = ["README", "MIT-LICENSE", "Rakefile", "init.rb", "{lib,tasks,test,rails}/**/*"].map do |glob|
  Dir[glob]
end.flatten

Gem::Specification.new do |s|
  s.name = "skywriter_client"
  s.version = "0.1.0"
  s.authors = ["thoughtbot"]
  s.date = "2010-06-04"
  s.email = "support@thoughtbot.com"
  s.extra_rdoc_files = ["README"]
  s.files = include_files
  s.homepage = "http://github.com/thoughtbot/skywriter_client"
  s.rdoc_options = ["--line-numbers", "--main"]
  s.require_path = "lib"
  s.rubyforge_project = "skywriter_client"
  s.rubygems_version = "1.3.5"
  s.summary = "Client for the SkyWriter content management service"

  s.add_dependency 'httparty'

  s.add_development_dependency 'shoulda'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'bourne'
  s.add_development_dependency 'activesupport'
  s.add_development_dependency 'activerecord'
  s.add_development_dependency 'activepack'
  s.add_development_dependency 'webmock'
end
