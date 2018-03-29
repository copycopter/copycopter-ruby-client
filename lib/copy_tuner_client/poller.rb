require 'thread'
require 'copy_tuner_client/cache'
require 'copy_tuner_client/queue_with_timeout'

module CopyTunerClient
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
      @command_queue = CopyTunerClient::QueueWithTimeout.new
      @mutex         = Mutex.new
      @thread        = nil
    end

    def start
      @mutex.synchronize do
        if @thread.nil?
          @logger.info 'start poller thread'
          @thread = Thread.new { poll } or logger.error("Couldn't start poller thread")
        end
      end
    end

    def stop
      @mutex.synchronize do
        @command_queue.uniq_push(:stop)
        @thread.join if @thread
        @thread = nil
      end
    end

    def start_sync
      @command_queue.uniq_push(:sync)
    end

    def wait_for_download
      @cache.wait_for_download
    end

    private

    attr_reader :cache, :logger, :polling_delay

    def poll
      loop do
        cache.sync
        logger.flush if logger.respond_to?(:flush)
        begin
          command = @command_queue.pop_with_timeout(polling_delay)
          break if command == :stop
        rescue ThreadError
          # timeout
        end
      end
      @logger.info 'stop poller thread'
    rescue InvalidApiKey => error
      logger.error(error.message)
    end
  end
end
