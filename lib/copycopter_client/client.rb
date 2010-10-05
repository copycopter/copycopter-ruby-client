module CopycopterClient
  # Communicates with the Copycopter server
  class Client
    def initialize(options)
      [:protocol, :api_key, :host, :port].each do |option|
        instance_variable_set("@#{option}", options[option])
      end
    end

    def download
      response = Net::HTTP.get_response(blurbs_url)
      JSON.parse(response.body)
    end

    private

    attr_reader :protocol, :host, :port, :api_key

    def blurbs_url
      url("published_blurbs")
    end

    def url(resource)
      URI.parse("#{protocol}://#{host}:#{port}/api/v2/projects/#{api_key}/#{resource}")
    end
  end
end
