require 'net/http'
require 'net/https'
require 'rubygems'
require 'active_support'
require 'httparty'
require 'copycopter_client/configuration'
require 'copycopter_client/client'
require 'copycopter_client/helper'

# Plugin for applications to store their copy in a remote service to be editable by clients
module CopycopterClient

  VERSION = "0.9.0"
  API_VERSION = "1.0"
  LOG_PREFIX = "** [Copycopter] "

  HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError]

  HEADERS = {
    'Content-type'             => 'text/xml',
    'Accept'                   => 'text/xml, application/xml'
  }

  class << self
    # The client object is responsible for retrieving and storing information
    # in the Copycopter server
    attr_accessor :client

    # A Copycopter configuration object. Must act like a hash and return sensible
    # values for all Copycopter configuration options. See CopycopterClient::Configuration.
    attr_accessor :configuration

    def remote_lookup_disabled?
      Thread.current[:disabled] && Thread.current[:disabled] >= Time.now
    end

    def disable_remote_lookup
      Thread.current[:disabled] = Time.now + (5 * 60)
    end

    def enable_remote_lookup
      Thread.current[:disabled] = nil
    end


    # Tell the log that the client is good to go
    def report_ready
      write_verbose_log("Client #{VERSION} ready")
    end

    # Prints out the environment info to the log for debugging help
    def report_environment_info
      write_verbose_log("Environment Info: #{environment_info}")
    end

    # Prints out the response body from Copycopter for debugging help
    def report_response_body(response)
      write_verbose_log("Response from Copycopter: \n#{response}")
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
    #   CopycopterClient.configure do |config|
    #     config.api_key = '1234567890abcdef'
    #     config.secure  = false
    #   end
    def configure(silent = false)
      self.configuration ||= Configuration.new
      yield(configuration)
      self.client = Client.new(configuration)
      report_ready unless silent
    end

    def copy_for(key, default = nil)
      return default if remote_lookup_disabled?
      if !configuration.test?
        result = fetch(key, default)

        if result && result['blurb']
          "#{result['blurb']['content']} #{edit_link(result['blurb']) if !configuration.public?}"
        else
          result
        end
      else
        default
      end
    rescue *HTTP_ERRORS
      disable_remote_lookup
      default
    end
    alias_method :s, :copy_for

    private

    def fetch(key, default = nil)
      perform_caching(key) do
        options  = { :key => key, :environment => configuration[:environment_name] }
        response = CopycopterClient.client.get(options)

        if response.code != 200
          CopycopterClient.client.create(options.merge(:content => default))
          default
        else
          if response['blurb']
            response
          else
            response.body
          end
        end
      end
    end

    def perform_caching(key, &block)
      if configuration.public? && configuration.cache_enabled
        Rails.cache.fetch("copycopter.#{key}", :expires_in => configuration.cache_expires_in, &block)
      else
        yield
      end
    end

    def edit_link(blurb)
      "<a target='_blank' href='#{url}/projects/#{blurb["project_id"]}/blurbs/#{blurb['id']}/edit'>Edit</a>"
    end

    def url
      URI.parse("#{configuration[:protocol]}://#{configuration[:host]}:#{configuration[:port]}")
    end

  end

end
