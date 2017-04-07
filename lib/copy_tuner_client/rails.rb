module CopyTunerClient
  # Responsible for Rails initialization
  module Rails
    # Sets up the logger, environment, name, project root, and framework name
    # for Rails applications. Must be called after framework initialization.
    def self.initialize
      CopyTunerClient.configure(false) do |config|
        config.environment_name = ::Rails.env
        config.logger           = if defined?(::Rails::Console)
          Logger.new('/dev/null')
        elsif defined?(::Rails) && ::Rails.env.development?
          Logger.new('log/copy_tuner.log')
        else
          ::Rails.logger
        end
        config.framework        = "Rails: #{::Rails::VERSION::STRING}"
        config.middleware       = ::Rails.configuration.middleware
      end
    end
  end
end

if defined?(::Rails::Railtie)
  require 'copy_tuner_client/engine'
else
  CopyTunerClient::Rails.initialize
end
