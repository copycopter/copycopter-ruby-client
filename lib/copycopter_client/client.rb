require 'net/http'
require 'net/https'

module CopycopterClient
  class ConnectionError < StandardError
  end

  # Communicates with the Copycopter server
  class Client
    HTTP_ERRORS = [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError,
                   Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
                   Net::ProtocolError]

    def initialize(options)
      [:protocol, :api_key, :host, :port, :public, :http_read_timeout,
        :http_open_timeout, :secure, :logger].each do |option|
        instance_variable_set("@#{option}", options[option])
      end
    end

    def download
      connect do |http|
        response = http.get(uri(download_resource))
        logger.info("#{LOG_PREFIX}Downloaded translations")
        JSON.parse(response.body)
      end
    end

    def upload(data)
      connect do |http|
        http.post(uri("draft_blurbs"), data.to_json)
        logger.info("#{LOG_PREFIX}Uploaded missing translations")
      end
    end

    private

    attr_reader :protocol, :host, :port, :api_key, :http_read_timeout,
      :http_open_timeout, :secure, :logger

    def public?
      @public
    end

    def uri(resource)
      "/api/v2/projects/#{api_key}/#{resource}"
    end

    def download_resource
      if public?
        "published_blurbs"
      else
        "draft_blurbs"
      end
    end

    def connect
      http = Net::HTTP.new(host, port)
      http.open_timeout = http_open_timeout
      http.read_timeout = http_read_timeout
      http.use_ssl      = secure
      begin
        yield(http)
      rescue *HTTP_ERRORS => exception
        raise ConnectionError, "#{exception.class.name}: #{exception.message}"
      end
    end
  end
end
