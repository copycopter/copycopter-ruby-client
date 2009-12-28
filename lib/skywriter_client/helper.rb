require 'httparty'

module SkywriterClient
  # Helper for specifying content for skywriter
  module Helper

    def s(key, default=nil)
      response = SkywriterClient.client.get(key)
      if response != 200 && default
        response = SkywriterClient.client.create(key, default)
        default
      else
        response.body
      end
    end

  end
end
