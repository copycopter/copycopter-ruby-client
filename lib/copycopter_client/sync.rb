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
      @logger        = options[:logger]
    end

    def start
      Thread.new { poll }
    end

    def stop
      @stop = true
    end

    def [](key)
      lock { @blurbs[key] }
    end

    def []=(key, value)
      lock { @queued[key] = value }
    end

    def keys
      lock { @blurbs.keys }
    end

    private

    attr_reader :client, :polling_delay, :logger

    def poll
      until @stop
        sync
        sleep(polling_delay)
      end
    end

    def sync
      begin
        downloaded_blurbs = client.download
        lock { @blurbs = downloaded_blurbs }
        with_queued_changes do |queued|
          client.upload(queued)
        end
      rescue ConnectionError => error
        logger.error(LOG_PREFIX + error.message)
      end
    end

    def with_queued_changes
      changes_to_push = nil
      lock do
        unless @queued.empty?
          changes_to_push = @queued
          @queued = {}
        end
      end
      yield(changes_to_push) if changes_to_push
    end

    def lock(&block)
      @mutex.synchronize(&block)
    end
  end
end
