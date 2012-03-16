require 'net/http'
require 'net/https'
require 'copycopter_client/errors'

module CopycopterClient
  # Communicates with the Copycopter server. This class is used to actually
  # download and upload blurbs, as well as issuing deploys.
  #
  # A client is usually instantiated when {Configuration#apply} is called, and
  # the application will not need to interact with it directly.
  class Client
    # These errors will be rescued when connecting Copycopter.
    HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
                   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                   Net::ProtocolError, SocketError, OpenSSL::SSL::SSLError,
                   Errno::ECONNREFUSED]

    # Usually instantiated from {Configuration#apply}. Copies options.
    # @param options [Hash]
    # @option options [String] :api_key API key of the project to connect to
    # @option options [Fixnum] :port the port to connect to
    # @option options [Boolean] :public whether to download draft or published content
    # @option options [Fixnum] :http_read_timeout how long to wait before timing out when reading data from the socket
    # @option options [Fixnum] :http_open_timeout how long to wait before timing out when opening the socket
    # @option options [Boolean] :secure whether to use SSL
    # @option options [Logger] :logger where to log transactions
    # @option options [String] :ca_file path to root certificate file for ssl verification
    def initialize(options)
      [:api_key, :host, :port, :public, :http_read_timeout,
        :http_open_timeout, :secure, :logger, :ca_file].each do |option|
        instance_variable_set "@#{option}", options[option]
      end
    end

    # Downloads all blurbs for the given api_key.
    #
    # If the +public+ option was set to +true+, this will use published blurbs.
    # Otherwise, draft content is fetched.
    #
    # The client tracks ETags between download requests, and will return
    # without yielding anything if the server returns a not modified response.
    #
    # @yield [Hash] downloaded blurbs
    # @raise [ConnectionError] if the connection fails
    def download
      connect do |http|
        request = Net::HTTP::Get.new(uri(download_resource))
        request['If-None-Match'] = @etag
        response = http.request(request)

        if check response
          log 'Downloaded translations'
          yield JSON.parse(response.body)
        else
          log 'No new translations'
        end

        @etag = response['ETag']
      end
    end

    # Uploads the given hash of blurbs as draft content.
    # @param data [Hash] the blurbs to upload
    # @raise [ConnectionError] if the connection fails
    def upload(data)
      connect do |http|
        response = http.post(uri('draft_blurbs'), data.to_json, 'Content-Type' => 'application/json')
        check response
        log 'Uploaded missing translations'
      end
    end

    # Issues a deploy, marking all draft content as published for this project.
    # @raise [ConnectionError] if the connection fails
    def deploy
      connect do |http|
        response = http.post(uri('deploys'), '')
        check response
        log 'Deployed'
      end
    end

    private

    attr_reader :host, :port, :api_key, :http_read_timeout,
      :http_open_timeout, :secure, :logger, :ca_file

    def public?
      @public
    end

    def uri(resource)
      "/api/v2/projects/#{api_key}/#{resource}"
    end

    def download_resource
      if public?
        'published_blurbs'
      else
        'draft_blurbs'
      end
    end

    def connect
      http = Net::HTTP.new(host, port)
      http.open_timeout = http_open_timeout
      http.read_timeout = http_read_timeout
      http.use_ssl = secure
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.ca_file = ca_file

      begin
        yield http
      rescue *HTTP_ERRORS => exception
        raise ConnectionError, "#{exception.class.name}: #{exception.message}"
      end
    end

    def check(response)
      case response
      when Net::HTTPNotFound
        raise InvalidApiKey, "Invalid API key: #{api_key}"
      when Net::HTTPNotModified
        false
      when Net::HTTPSuccess
        true
      else
        raise ConnectionError, "#{response.code}: #{response.body}"
      end
    end

    def log(message)
      logger.info message
    end
  end
end
