module CopycopterClient
  # Communicates with the Copycopter server
  class Client
    def initialize(options)
      [:protocol, :api_key, :host, :port].each do |option|
        instance_variable_set("@#{option}", options[option])
      end
    end

    def download
      connect do |http|
        response = http.request_get(uri("published_blurbs"))
        JSON.parse(response.body)
      end
    end

    def upload(data)
      connect do |http|
        http.request_post(uri("draft_blurbs"), data.to_json)
      end
    end

    private

    attr_reader :protocol, :host, :port, :api_key

    def uri(resource)
      "/api/v2/projects/#{api_key}/#{resource}"
    end

    def connect
      result = nil
      Net::HTTP.start(host, port) do |http|
        result = yield(http)
      end
      result
    end
  end
end
