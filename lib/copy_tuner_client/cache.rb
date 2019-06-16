require 'thread'
require 'copy_tuner_client/client'
require 'copy_tuner_client/dotted_hash'

module CopyTunerClient
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
      @client = client
      @logger = options[:logger]
      @mutex = Mutex.new
      @exclude_key_regexp = options[:exclude_key_regexp]
      @locales = Array(options[:locales]).map(&:to_s)
      # mutable states
      @blurbs = {}
      @blank_keys = Set.new
      @queued = {}
      @started = false
      @downloaded = false
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
      return if @exclude_key_regexp && key.match?(@exclude_key_regexp)
      return if @blank_keys.member?(key)
      return if @locales.present? && !@locales.member?(key.split('.').first)
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
      lock { @blurbs.present? ? DottedHash.to_yaml(@blurbs) : nil }
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
      res = with_queued_changes do |queued|
        client.upload queued
      end

      @last_uploaded_at = Time.now.utc

      res
    rescue ConnectionError => error
      logger.error error.message
    end

    def download
      @started = true

      res = client.download do |downloaded_blurbs|
        blank_blurbs, blurbs = downloaded_blurbs.partition { |_key, value| value == '' }
        lock do
          @blank_keys = Set.new(blank_blurbs.to_h.keys)
          @blurbs = blurbs.to_h
        end
      end

      @last_downloaded_at = Time.now.utc

      res
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

    attr_reader :last_downloaded_at, :last_uploaded_at, :queued

    def inspect
      "#<CopyTunerClient::Cache:#{object_id}>"
    end

    def pending?
      @started && !@downloaded
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
        yield nil_value_to_empty(changes_to_push)
      end
    end

    def nil_value_to_empty(hash)
      hash.each do |k, v|
        if v.nil?
          hash[k] = ''.freeze
        elsif v.is_a?(Hash)
          nil_value_to_empty(v)
        end
      end
      hash
    end

    def lock(&block)
      @mutex.synchronize &block
    end
  end
end
