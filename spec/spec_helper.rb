require 'rubygems'
require 'rspec'
require 'bourne'
require 'sham_rack'
require 'webmock/rspec'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))

$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')

require 'copycopter_client'

Dir.glob(File.join(PROJECT_ROOT, 'spec', 'support', '**', '*.rb')).each do |file|
  require(file)
end

WebMock.disable_net_connect!
ShamRack.mount FakeCopycopterApp.new, 'copycopter.com', 80

RSpec.configure do |config|
  config.include ClientSpecHelpers
  config.include WebMock::API
  config.mock_with :mocha

  config.before do
    FakeCopycopterApp.reset
    reset_config
  end
end
