module CopyTunerClient
  # Responsible for Rails initialization
  module Rails
    # Sets up the logger, environment, name, project root, and framework name
    # for Rails applications. Must be called after framework initialization.
    def self.initialize
      CopyTunerClient.configure(false) do |config|
        config.environment_name = ::Rails.env
        config.logger           = ::Rails.logger
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
        config.middleware       = ::Rails.configuration.middleware
      end
    end
  end
end

if defined?(Rails::Railtie)
  require 'copy_tuner_client/railtie'
else
  CopyTunerClient::Rails.initialize
end
