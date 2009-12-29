require 'httparty'

module SkywriterClient
  # Communicates with the SkyWriter server
  class Client
    include HTTParty
    format :xml

    BLURBS_URI = ''.freeze

    def initialize(options = {})
      [:proxy_host, :proxy_port, :proxy_user, :proxy_pass, :protocol, :api_key,
       :host, :port, :secure, :http_open_timeout, :http_read_timeout].each do |option|
        instance_variable_set("@#{option}", options[option])
      end
      self.class.headers("X-API-KEY" => @api_key) if @api_key
    end

    def create(options = {})
      self.class.post "#{url}/environments/#{options[:environment]}/blurbs",
                      :body => { :blurb => { :content => options[:content],
                                             :key     => options[:key] }}
    end

    def get(options = {})
      self.class.get "#{url}/environments/#{options[:environment]}/blurbs/#{options[:key]}"
    end

    private

    attr_reader :proxy_host, :proxy_port, :proxy_user, :proxy_pass, :protocol,
      :host, :port, :secure, :http_open_timeout, :http_read_timeout

    def url
      URI.parse("#{protocol}://#{host}:#{port}")
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
