ENV['BUNDLE_GEMFILE'] ||= File.expand_path('rails3-Gemfile')

require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'cucumber/rake/task'
require 'spec/rake/spectask'
require 'yard'

desc 'Default: run specs and cucumber features on both Rails 2 and 3'
task :default => [:spec, :cucumber, 'cucumber:rails2']

desc 'Test the copycopter_client plugin.'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/copycopter_client/**/*_spec.rb']
end

namespace :cucumber do
  desc "Run cucumber features on Rails 2"
  task :rails2 do
    ENV['BUNDLE_GEMFILE'] = File.expand_path('rails2-Gemfile')
    exec("rake cucumber")
  end
end

desc "Run cucumber features"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = ['--tags', '~@wip',
                     '--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end

eval("$specification = begin; #{IO.read('copycopter_client.gemspec')}; end")
Rake::GemPackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end

