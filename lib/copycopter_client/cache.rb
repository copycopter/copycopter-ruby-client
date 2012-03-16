require 'thread'
require 'copycopter_client/client'

module CopycopterClient
  # Manages synchronization of copy between {I18nBackend} and {Client}. Acts
  # like a Hash. Applications using the client will not need to interact with
  # this class directly.
  #
  # Responsible for locking down access to data used by both threads.
  class Cache
    # Usually instantiated when {Configuration#apply} is invoked.
    # @param client [Client] the client used to fetch and upload data
    # @param options [Hash]
    # @option options [Logger] :logger where errors should be logged
    def initialize(client, options)
      @blurbs = {}
      @client = client
      @downloaded = false
      @logger = options[:logger]
      @mutex = Mutex.new
      @queued = {}
      @started = false
    end

    # Returns content for the given blurb.
    # @param key [String] the key of the desired blurb
    # @return [String] the contents of the blurb
    def [](key)
      lock { @blurbs[key] }
    end

    # Sets content for the given blurb. The content will be pushed to the
    # server on the next flush.
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

    # Yaml representation of all blurbs
    # @return [String] yaml
    def export
      keys = {}
      lock do
        @blurbs.sort.each do |(blurb_key, value)|
          current = keys
          yaml_keys = blurb_key.split('.')

          0.upto(yaml_keys.size - 2) do |i|
            key = yaml_keys[i]

            # Overwrite en.key with en.sub.key
            unless current[key].class == Hash
              current[key] = {}
            end

            current = current[key]
          end

          current[yaml_keys.last] = value
        end
      end

      unless keys.size < 1
        keys.to_yaml
      end
    end

    # Waits until the first download has finished.
    def wait_for_download
      if pending?
        logger.info 'Waiting for first download'

        if logger.respond_to? :flush
          logger.flush
        end

        while pending?
          sleep 0.1
        end
      end
    end

    def flush
      with_queued_changes do |queued|
        client.upload queued
      end
    rescue ConnectionError => error
      logger.error error.message
    end

    def download
      @started = true

      client.download do |downloaded_blurbs|
        downloaded_blurbs.reject! { |key, value| value == '' }
        lock { @blurbs = downloaded_blurbs }
      end
    rescue ConnectionError => error
      logger.error error.message
    ensure
      @downloaded = true
    end

    # Downloads and then flushes
    def sync
      download
      flush
    end

    private

    attr_reader :client, :logger

    def with_queued_changes
      changes_to_push = nil

      lock do
        unless @queued.empty?
          changes_to_push = @queued
          @queued = {}
        end
      end

      if changes_to_push
        yield changes_to_push
      end
    end

    def lock(&block)
      @mutex.synchronize &block
    end

    def pending?
      @started && !@downloaded
    end
  end
end
