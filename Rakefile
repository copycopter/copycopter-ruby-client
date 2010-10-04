require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'cucumber/rake/task'
require 'spec/rake/spectask'

desc 'Default: run specs and cucumber features'
task :default => [:spec, :cucumber]

desc 'Test the copycopter_client plugin.'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--options', "spec/spec.opts"]
  t.spec_files = FileList['spec/copycopter_client/**/*_spec.rb']
end

Cucumber::Rake::Task.new(:cucumber) do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'progress')]
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', 'TESTING.rdoc']
  end
rescue LoadError
end
