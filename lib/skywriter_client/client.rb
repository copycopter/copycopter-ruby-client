module SkywriterClient
  # Sends out the notice to Hoptoad
  class Client

    BLURBS_URI = '/notifier_api/v2/notices/'.freeze

    def initialize(options = {})
      [:proxy_host, :proxy_port, :proxy_user, :proxy_pass, :protocol,
        :host, :port, :secure, :http_open_timeout, :http_read_timeout].each do |option|
        instance_variable_set("@#{option}", options[option])
      end
    end

    private

    attr_reader :proxy_host, :proxy_port, :proxy_user, :proxy_pass, :protocol,
      :host, :port, :secure, :http_open_timeout, :http_read_timeout

    def url
      URI.parse("#{protocol}://#{host}:#{port}").merge(NOTICES_URI)
    end

    def log(level, message, response = nil)
      logger.send level, LOG_PREFIX + message if logger
      SkywriterClient.report_environment_info
      SkywriterClient.report_response_body(response.body) if response && response.respond_to?(:body)
    end

    def logger
      SkywriterClient.logger
    end

  end
end
