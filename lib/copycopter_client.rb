require 'copycopter_client/version'
require 'copycopter_client/configuration'

# Top-level interface to the Copycopter client.
#
# Most applications should only need to use the {.configure}
# method, which will setup all the pieces and begin synchronization when
# appropriate.
module CopycopterClient
  class << self
    # @return [Client] instance used to communicate with the Copycopter server.
    # This is set when {.configure} is called.
    attr_accessor :client

    # @return [Configuration] current client configuration
    # Must act like a hash and return sensible values for all Copycopter
    # configuration options. Usually set when {.configure} is called.
    attr_accessor :configuration

    # @return [Sync] instance used to synchronize changes.
    # This is set when {.configure} is called.
    attr_accessor :sync
  end

  # Issues a new deploy, marking all draft blurbs as published.
  # This is called when the copycopter:deploy rake task is invoked.
  def self.deploy
    client.deploy
  end

  # Starts the polling process.
  # This is called from Unicorn worker processes.
  def self.start_sync
    sync.start
  end

  # Call this method to modify defaults in your initializers.
  #
  # @example
  #   CopycopterClient.configure do |config|
  #     config.api_key = '1234567890abcdef'
  #     config.secure  = false
  #   end
  #
  # @param apply [Boolean] (internal) whether the configuration should be applied yet.
  #
  # @yield [Configuration] the configuration to be modified
  def self.configure(apply = true)
    self.configuration ||= Configuration.new
    yield(configuration)
    configuration.apply if apply
  end
end

if defined?(Rails)
  require 'copycopter_client/rails'
end

