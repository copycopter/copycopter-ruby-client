require 'copycopter_client/i18n_backend'
require 'copycopter_client/client'
require 'copycopter_client/sync'

module CopycopterClient
  # Used to set up and modify settings for the client.
  class Configuration

    OPTIONS = [:api_key, :development_environments, :environment_name, :host,
        :http_open_timeout, :http_read_timeout, :client_name, :client_url,
        :client_version, :port, :protocol, :proxy_host, :proxy_pass,
        :proxy_port, :proxy_user, :secure, :cache_enabled,
        :cache_expires_in, :polling_delay].freeze

    # The API key for your project, found on the project edit form.
    attr_accessor :api_key

    # The host to connect to (defaults to copycopter.com).
    attr_accessor :host

    # The port on which your Copycopter server runs (defaults to 443 for secure
    # connections, 80 for insecure connections).
    attr_accessor :port

    # +true+ for https connections, +false+ for http connections.
    attr_accessor :secure

    # The HTTP open timeout in seconds (defaults to 2).
    attr_accessor :http_open_timeout

    # The HTTP read timeout in seconds (defaults to 5).
    attr_accessor :http_read_timeout

    # The hostname of your proxy server (if using a proxy)
    attr_accessor :proxy_host

    # The port of your proxy server (if using a proxy)
    attr_accessor :proxy_port

    # The username to use when logging into your proxy server (if using a proxy)
    attr_accessor :proxy_user

    # The password to use when logging into your proxy server (if using a proxy)
    attr_accessor :proxy_pass

    # A list of environments in content should be editable
    attr_accessor :development_environments

    # A list of environments in which the server should not be contacted
    attr_accessor :test_environments

    # The name of the environment the application is running in
    attr_accessor :environment_name

    # The name of the client library being used to send notifications (such as "Copycopter Client")
    attr_accessor :client_name

    # The version of the client library being used to send notifications (such as "1.0.2")
    attr_accessor :client_version

    # The url of the client library being used
    attr_accessor :client_url

    # +true+ to enable caching, +false+ to disable caching
    attr_accessor :cache_enabled

    # The time, in seconds, the cache should expire.
    attr_accessor :cache_expires_in

    # The time, in seconds, in between each sync to the server.
    attr_accessor :polling_delay

    alias_method :secure?, :secure

    def initialize
      @secure                   = false
      @host                     = 'copycopter.com'
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @development_environments = %w(development staging)
      @test_environments        = %w(test cucumber)
      @client_name              = 'Copycopter Client'
      @client_version           = VERSION
      @client_url               = 'http://copycopter.com'
      @cache_enabled            = false
      @applied                  = false
      @polling_delay            = 300
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    def to_hash
      base_options = { :public => public? }
      OPTIONS.inject(base_options) do |hash, option|
        hash.merge(option.to_sym => send(option))
      end
    end

    # Returns a hash of all configurable options merged with +hash+
    #
    # @param [Hash] hash A set of configuration options that will take precedence over the defaults
    def merge(hash)
      to_hash.merge(hash)
    end

    # Determines if the content will be editable
    # @return [Boolean] Returns +false+ if in a development environment, +true+ otherwise.
    def public?
      !(development_environments + test_environments).include?(environment_name)
    end

    # Determines if the content will fetched from the server
    # @return [Boolean] Returns +true+ if in a test environment, +false+ otherwise.
    def test?
      test_environments.include?(environment_name)
    end

    def applied?
      @applied
    end

    def apply
      client = Client.new(to_hash)
      sync = Sync.new(client, to_hash)
      I18n.backend = I18nBackend.new(sync)
      @applied = true
      sync.start unless test?
    end

    def port
      @port || default_port
    end

    def protocol
      if secure?
        'https'
      else
        'http'
      end
    end

    private

    def default_port
      if secure?
        443
      else
        80
      end
    end
  end

  class << self
    # Call this method to modify defaults in your initializers.
    #
    # @example
    #   CopycopterClient.configure do |config|
    #     config.api_key = '1234567890abcdef'
    #     config.secure  = false
    #   end
    def configure(apply = true)
      self.configuration ||= Configuration.new
      yield(configuration)
      configuration.apply if apply
    end

    # A Copycopter configuration object. Must act like a hash and return sensible
    # values for all Copycopter configuration options. See CopycopterClient::Configuration.
    attr_accessor :configuration

  end
end
