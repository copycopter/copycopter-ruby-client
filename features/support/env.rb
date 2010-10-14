require 'sham_rack'
require 'aruba'
require 'rails/version'

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
$LOAD_PATH << File.join(PROJECT_ROOT, 'lib')
require "copycopter_client/version"

Before do
  if ENV['debug']
    @puts = true
    @announce_stdout = true
    @announce_stderr = true
    @announce_cmd = true
    @announce_dir = true
    @announce_env = true
  end
end
