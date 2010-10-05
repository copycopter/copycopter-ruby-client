require 'copycopter_client/sync'

module CopycopterClient
  class Sync
    def initialize(client, options)
      @client = client
      @blurbs = {}
    end

    def start
      @blurbs = client.download
    end

    def [](key)
      blurbs[key]
    end

    def keys
      blurbs.keys
    end

    private

    attr_reader :client, :blurbs
  end
end
