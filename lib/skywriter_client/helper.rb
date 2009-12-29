require 'httparty'

module SkywriterClient
  # Helper methods for SkyWriter
  module Helper

    def sky_write(key, default=nil)
      SkywriterClient.sky_write(key, default)
    end

    def s(key, default=nil)
      SkywriterClient.sky_write(key, default)
    end

  end
end
