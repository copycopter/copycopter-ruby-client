require 'sham_rack'
require 'aruba/cucumber'
require 'rails/version'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')
require "copycopter_client/version"

Before do
  @aruba_timeout_seconds = 15
end

