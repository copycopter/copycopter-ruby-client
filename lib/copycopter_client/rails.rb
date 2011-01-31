module CopycopterClient
  # Responsible for Rails initialization
  module Rails
    # Sets up the logger, environment, name, project root, and framework name
    # for Rails applications. Must be called after framework initialization.
    def self.initialize
      CopycopterClient.configure(false) do |config|
        config.environment_name = ::Rails.env
        config.logger           = ::Rails.logger
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
        config.middleware       = ::Rails.configuration.middleware
      end
    end
  end
end

if defined?(Rails::Railtie)
  require 'copycopter_client/railtie'
else
  CopycopterClient::Rails.initialize
end

