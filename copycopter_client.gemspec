# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'copycopter_client/version'

Gem::Specification.new do |s|
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_dependency 'json'
  s.add_development_dependency 'appraisal', '~> 0.4'
  s.add_development_dependency 'aruba', '~> 0.3.2'
  s.add_development_dependency 'bourne'
  s.add_development_dependency 'cucumber', '~> 0.10.0'
  s.add_development_dependency 'i18n'
  s.add_development_dependency 'rails', '~> 3.1.0'
  s.add_development_dependency 'rake', '0.9.2'
  s.add_development_dependency 'rspec', '~> 2.3'
  s.add_development_dependency 'sham_rack'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'sqlite3-ruby'
  s.add_development_dependency 'thin'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'yard'
  s.authors = ['thoughtbot']
  s.email  = 'support@thoughtbot.com'
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/copycopter/copycopter-ruby-client'
  s.name  = 'copycopter_client'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'Client for the Copycopter copy management service'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = CopycopterClient::VERSION
end
