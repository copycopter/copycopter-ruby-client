require 'rubygems'
require 'rspec'
require 'bourne'
require 'sham_rack'
require 'webmock/rspec'
require 'active_support'
require 'active_support/core_ext'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'copy_tuner_client'

Dir.glob(File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')).each do |file|
  require(file)
end

WebMock.disable_net_connect!
ShamRack.at('copy-tuner.com', 443).mount(FakeCopyTunerApp.new)

RSpec.configure do |config|
  config.include ClientSpecHelpers
  config.include WebMock::API
  config.mock_with :mocha

  config.before do
    FakeCopyTunerApp.reset
    reset_config
  end
end
