require 'net/http'
require 'net/https'
require 'rubygems'
require 'active_support'
require 'skywriter_client/configuration'
require 'skywriter_client/client'

# Plugin for applications to store their copy in a remote service to be editable by clients
module SkywriterClient

  VERSION = "0.9.0"
  API_VERSION = "1.0"
  LOG_PREFIX = "** [SkyWriter] "

  HEADERS = {
    'Content-type'             => 'text/xml',
    'Accept'                   => 'text/xml, application/xml'
  }

  class << self
    # The client object is responsible for retrieving and storing information
    # in the SkyWriter server
    attr_accessor :sender

    # A SkyWriter configuration object. Must act like a hash and return sensible
    # values for all SkyWriter configuration options. See SkywriterClient::Configuration.
    attr_accessor :configuration

    # Tell the log that the client is good to go
    def report_ready
      write_verbose_log("Client #{VERSION} ready")
    end

    # Prints out the environment info to the log for debugging help
    def report_environment_info
      write_verbose_log("Environment Info: #{environment_info}")
    end

    # Prints out the response body from Hoptoad for debugging help
    def report_response_body(response)
      write_verbose_log("Response from SkyWriter: \n#{response}")
    end

    # Returns the Ruby version, Rails version, and current Rails environment
    def environment_info
      info = "[Ruby: #{RUBY_VERSION}]"
      info << " [Rails: #{::Rails::VERSION::STRING}]" if defined?(Rails)
      info << " [Env: #{configuration.environment_name}]"
    end

    # Writes out the given message to the #logger
    def write_verbose_log(message)
      logger.info LOG_PREFIX + message if logger
    end

    # Look for the Rails logger currently defined
    def logger
      if defined?(Rails.logger)
        Rails.logger
      elsif defined?(RAILS_DEFAULT_LOGGER)
        RAILS_DEFAULT_LOGGER
      end
    end

    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   SkywriterClient.configure do |config|
    #     config.api_key = '1234567890abcdef'
    #     config.secure  = false
    #   end
    def configure(silent = false)
      self.configuration ||= Configuration.new
      yield(configuration)
      #self.client = Client.new(configuration)
      report_ready unless silent
    end

  end

end
