require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'yard'

desc 'Default: run the specs.'
task default: [:spec]

desc 'Test the copy_tuner_client plugin.'
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ['--color', '--format progress']
  t.pattern = 'spec/copy_tuner_client/**/*_spec.rb'
end

YARD::Rake::YardocTask.new do |t|
  t.files = ['lib/**/*.rb']
end
