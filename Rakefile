require 'rubygems'
require 'bundler/setup'
require 'appraisal'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'cucumber/rake/task'
require 'spec/rake/spectask'
require 'yard'

desc 'Default: run the specs and features.'
task :default => :spec do
  system("rake -s appraisal cucumber;")
end

desc 'Test the copycopter_client plugin.'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/copycopter_client/**/*_spec.rb']
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

