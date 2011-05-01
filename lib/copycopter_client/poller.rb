require 'thread'
require 'copycopter_client/cache'

module CopycopterClient
  # Starts a background thread that continually resynchronizes with the remote
  # server using the given {Cache} after a set delay.
  class Poller
    # @param options [Hash]
    # @option options [Logger] :logger where errors should be logged
    # @option options [Fixnum] :polling_delay how long to wait in between requests
    def initialize(cache, options)
      @cache         = cache
      @polling_delay = options[:polling_delay]
      @logger        = options[:logger]
      @stop          = false
    end

    def start
      Thread.new { poll } or logger.error("Couldn't start poller thread")
    end

    def stop
      @stop = true
    end

    private

    attr_reader :cache, :logger, :polling_delay

    def poll
      until @stop
        cache.sync
        logger.flush if logger.respond_to?(:flush)
        delay
      end
    rescue InvalidApiKey => error
      logger.error(error.message)
    end

    def delay
      sleep(polling_delay)
    end
  end
end
