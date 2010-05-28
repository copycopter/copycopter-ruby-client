module SkywriterClient
  # Used to set up and modify settings for the client.
  class Configuration

    OPTIONS = [:api_key, :development_environments, :environment_name, :host,
        :http_open_timeout, :http_read_timeout, :client_name, :client_url,
        :client_version, :port, :protocol, :proxy_host, :proxy_pass,
        :proxy_port, :proxy_user, :secure, :cache_enabled,
        :cache_expires_in].freeze

    # The API key for your project, found on the project edit form.
    attr_accessor :api_key

    # The host to connect to (defaults to skywriterapp.com).
    attr_accessor :host

    # The port on which your SkyWriter server runs (defaults to 443 for secure
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

    # The name of the client library being used to send notifications (such as "SkyWriter Client")
    attr_accessor :client_name

    # The version of the client library being used to send notifications (such as "1.0.2")
    attr_accessor :client_version

    # The url of the client library being used
    attr_accessor :client_url

    # +true+ to enable caching, +false+ to disable caching
    attr_accessor :cache_enabled

    # The time, in seconds, the cache should expire.
    attr_accessor :cache_expires_in

    alias_method :secure?, :secure

    def initialize
      @secure                   = false
      @host                     = 'skywriterapp.com'
      @http_open_timeout        = 2
      @http_read_timeout        = 5
      @development_environments = %w(development staging)
      @test_environments        = %w(test cucumber)
      @client_name              = 'SkyWriter Client'
      @client_version           = VERSION
      @client_url               = 'http://skywriterapp.com'
      @cache_enabled            = true
    end

    # Allows config options to be read like a hash
    #
    # @param [Symbol] option Key for a given attribute
    def [](option)
      send(option)
    end

    # Returns a hash of all configurable options
    def to_hash
      OPTIONS.inject({}) do |hash, option|
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

end
