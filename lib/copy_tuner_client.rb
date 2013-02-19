require 'copy_tuner_client/version'
require 'copy_tuner_client/configuration'

# Top-level interface to the CopyTuner client.
#
# Most applications should only need to use the {.configure}
# method, which will setup all the pieces and begin synchronization when
# appropriate.
module CopyTunerClient
  class << self
    # @return [Configuration] current client configuration
    # Must act like a hash and return sensible values for all CopyTuner
    # configuration options. Usually set when {.configure} is called.
    attr_accessor :configuration

    # @return [Poller] instance used to poll for changes.
    # This is set when {.configure} is called.
    attr_accessor :poller
  end

  # Issues a new deploy, marking all draft blurbs as published.
  # This is called when the copy_tuner:deploy rake task is invoked.
  def self.deploy
    client.deploy
  end

  # Issues a new export, returning yaml representation of blurb cache.
  # This is called when the copy_tuner:export rake task is invoked.
  def self.export
    cache.export
  end

  # Starts the polling process.
  def self.start_poller
    poller.start
  end

  # Flush queued changed synchronously
  def self.flush
    cache.flush
  end

  def self.cache
    CopyTunerClient.configuration.cache
  end

  def self.client
    CopyTunerClient.configuration.client
  end

  # Call this method to modify defaults in your initializers.
  #
  # @example
  #   CopyTunerClient.configure do |config|
  #     config.api_key = '1234567890abcdef'
  #     config.host = 'your-copy-tuner-server.herokuapp.com'
  #     config.secure = true
  #   end
  #
  # @param apply [Boolean] (internal) whether the configuration should be applied yet.
  #
  # @yield [Configuration] the configuration to be modified
  def self.configure(apply = true)
    self.configuration ||= Configuration.new
    yield configuration

    if apply
      configuration.apply
    end
  end
end

if defined? ::Rails
  require 'copy_tuner_client/rails'
end
