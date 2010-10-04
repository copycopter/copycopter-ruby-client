require 'rubygems'
require 'spec'
require 'spec/autorun'
require 'bourne'
require 'action_controller'
require 'action_controller/test_process'
require 'active_record'
require 'webmock/rspec'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

$LOAD_PATH << File.join(PROJECT_ROOT, "lib")

require "copycopter_client"

Dir.glob(File.join(PROJECT_ROOT, "spec", "support", "**", "*.rb")).each do |file|
  require(file)
end

include WebMock
WebMock.disable_net_connect!
RAILS_DEFAULT_LOGGER = FakeLogger.new

Spec::Runner.configure do |config|
  config.include ClientSpecHelpers
  config.include WebMock
  config.mock_with :mocha
end

