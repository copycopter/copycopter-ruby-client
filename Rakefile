require 'bundler/gem_tasks'
require 'appraisal'
require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'yard'

desc 'Default: run the specs and features.'
task :default => [:spec, :cucumber]

desc 'Test the copy_tuner_client plugin.'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color', "--format progress"]
  t.pattern = 'spec/copy_tuner_client/**/*_spec.rb'
end

desc "Run cucumber features"
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = [
    '--tags', '~@wip',
    '--format', (ENV['CUCUMBER_FORMAT'] || 'progress')
  ]
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb']
end
