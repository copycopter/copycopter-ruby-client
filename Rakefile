require 'rubygems'
require 'bundler/setup'
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'cucumber/rake/task'
require 'spec/rake/spectask'
require 'yard'

desc 'Default: run specs and cucumber features'
task :default => [:spec, :cucumber]

desc 'Test the copycopter_client plugin.'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/copycopter_client/**/*_spec.rb']
end

namespace :cucumber do
  Cucumber::Rake::Task.new(:ok) do |t|
    t.fork = true
    t.cucumber_opts = ['--tags', '~@wip',
                       '--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
  end

  Cucumber::Rake::Task.new(:wip) do |t|
    t.fork = true
    t.cucumber_opts = ['--tags', '@wip',
                       '--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
  end

  task :all => [:ok, :wip]
end

task :cucumber => 'cucumber:ok'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb', 'TESTING.rdoc']
end

