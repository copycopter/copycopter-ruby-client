require 'thread'
require 'copycopter_client/client'

module CopycopterClient
  # Manages synchronization of copy between {I18nBackend} and {Client}. Acts
  # like a Hash. Applications using the client will not need to interact with
  # this class directly.
  #
  # Responsible for:
  # * Starting and running the background polling thread
  # * Locking down access to data used by both threads
  class Sync
    # Usually instantiated when {Configuration#apply} is invoked.
    # @param client [Client] the client used to fetch and upload data
    # @param options [Hash]
    # @option options [Fixnum] :polling_delay the number of seconds in between each synchronization with the server
    # @option options [Logger] :logger where errors should be logged
    def initialize(client, options)
      @client        = client
      @blurbs        = {}
      @polling_delay = options[:polling_delay]
      @stop          = false
      @queued        = {}
      @mutex         = Mutex.new
      @logger        = options[:logger]
      @pending       = false
    end

    # Starts the polling thread. The polling thread doesn't run in test environments.
    #
    # If this sync was created from a master spawner (as in the case for
    # phusion passenger), it will instead register after fork hooks so that the
    # poller starts in each spawned process.
    def start
      if spawner?
        logger.info(LOG_PREFIX + "Not polling from spawner process")
        register_spawn_hooks
      else
        logger.info(LOG_PREFIX + "Starting poller")
        @pending = true
        Thread.new { poll }
      end
    end

    # Stops the polling thread after the next run.
    def stop
      @stop = true
    end

    # Returns content for the given blurb.
    # @param key [String] the key of the desired blurb
    # @return [String] the contents of the blurb
    def [](key)
      lock { @blurbs[key] }
    end

    # Sets content for the given blurb. The content will be pushed to the
    # server on the next poll.
    # @param key [String] the key of the blurb to update
    # @param value [String] the new contents of the blurb
    def []=(key, value)
      lock { @queued[key] = value }
    end

    # Keys for all blurbs stored on the server.
    # @return [Array<String>] keys
    def keys
      lock { @blurbs.keys }
    end

    # Waits until the first download has finished.
    def wait_for_download
      if @pending
        logger.info(LOG_PREFIX + "Waiting for first sync")
        while @pending
          sleep(0.1)
        end
      end
    end

    private

    attr_reader :client, :polling_delay, :logger

    def poll
      until @stop
        sync
        sleep(polling_delay)
      end
    rescue InvalidApiKey => error
      logger.error(LOG_PREFIX + error.message)
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
    ensure
      @pending = false
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

    def spawner?
      $0.include?("ApplicationSpawner")
    end

    def register_spawn_hooks
      if defined?(PhusionPassenger)
        PhusionPassenger.on_event(:starting_worker_process) do |forked|
          start
        end
      end
    end
  end
end
