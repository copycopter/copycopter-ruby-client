require 'copycopter_client/sync'

module CopycopterClient
  class Sync
    def initialize(client, options)
      @client        = client
      @blurbs        = {}
      @polling_delay = options[:polling_delay]
      @stop          = false
      @queued        = {}
    end

    def start
      Thread.new { poll }
    end

    def stop
      @stop = true
    end

    def [](key)
      blurbs[key]
    end

    def []=(key, value)
      @queued[key] = value
    end

    def keys
      blurbs.keys
    end

    private

    attr_reader :client, :blurbs, :polling_delay

    def poll
      until @stop
        @blurbs = client.download
        with_queued_changes do |queued|
          client.upload(queued)
        end
        sleep(polling_delay)
      end
    end

    def with_queued_changes
      unless @queued.empty?
        queued = @queued
        @queued = {}
        yield(queued)
      end
    end
  end
end
