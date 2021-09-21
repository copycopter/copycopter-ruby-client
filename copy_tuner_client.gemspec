# -*- encoding: utf-8 -*-
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'copy_tuner_client/version'

Gem::Specification.new do |s|
  s.required_ruby_version = '>= 2.5.0'
  s.add_dependency 'i18n', '>= 0.5.0'
  s.add_dependency 'json'
  s.add_dependency 'nokogiri'
  s.add_development_dependency 'rails', '~> 6.1'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sham_rack'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'thin'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'yard'
  s.authors = ['SonicGarden']
  s.email  = 'info@sonicgarden.jp'
  s.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.homepage = 'https://github.com/SonicGarden/copy-tuner-ruby-client'
  s.name  = 'copy_tuner_client'
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.summary = 'Client for the CopyTuner copy management service'
  s.test_files = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.version = CopyTunerClient::VERSION
end
