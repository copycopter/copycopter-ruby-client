require 'thread'
require 'copycopter_client/sync'

module CopycopterClient
  class Sync
    def initialize(client, options)
      @client        = client
      @blurbs        = {}
      @polling_delay = options[:polling_delay]
      @stop          = false
      @queued        = {}
      @mutex         = Mutex.new
    end

    def start
      Thread.new { poll }
    end

    def stop
      @stop = true
    end

    def [](key)
      sync { @blurbs[key] }
    end

    def []=(key, value)
      sync { @queued[key] = value }
    end

    def keys
      sync { @blurbs.keys }
    end

    private

    attr_reader :client, :polling_delay

    def poll
      until @stop
        downloaded_blurbs = client.download
        sync { @blurbs = downloaded_blurbs }
        with_queued_changes do |queued|
          client.upload(queued)
        end
        sleep(polling_delay)
      end
    end

    def with_queued_changes
      changes_to_push = nil
      sync do
        unless @queued.empty?
          changes_to_push = @queued
          @queued = {}
        end
      end
      yield(changes_to_push) if changes_to_push
    end

    def sync(&block)
      @mutex.synchronize(&block)
    end
  end
end
