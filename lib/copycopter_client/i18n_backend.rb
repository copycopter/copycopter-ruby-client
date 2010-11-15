require 'i18n'

module CopycopterClient
  # I81n implementation designed to synchronize with Copycopter.
  #
  # Expects an object that acts like a Hash, responding to +[]+, +[]=+, and +keys+.
  #
  # This backend will be used as the default I81n backend when the client is
  # configured, so you will not need to instantiate this class from the
  # application. Instead, just use methods on the I81n class.
  #
  # If a fallback backend is provided, keys available in the fallback backend
  # will be used as defaults when those keys aren't available on the Copycopter
  # server.
  class I18nBackend
    include I18n::Backend::Base

    # Usually instantiated when {Configuration#apply} is invoked.
    # @param sync [Sync] must act like a hash, returning and accept blurbs by key.
    # @param options [Hash]
    # @option options [I18n::Backend::Base] :fallback_backend I18n backend where missing translations can be found
    def initialize(sync, options)
      @sync     = sync
      @base_url = URI.parse("#{options[:protocol]}://#{options[:host]}:#{options[:port]}")
      @fallback = options[:fallback_backend]
    end

    # This is invoked by frameworks when locales should be loaded. The
    # Copycopter client loads content in the background, so this method waits
    # until the first download is complete.
    def reload!
      sync.wait_for_download
    end

    # Translates the given local and key. See the I81n API documentation for details.
    #
    # Because the Copycopter API only supports copy text and doesn't support
    # nested structures or arrays, the fallback value will be returned without
    # using the Copycopter API if that value doesn't respond to to_str.
    #
    # @return [Object] the translated key (usually a String)
    def translate(locale, key, options = {})
      fallback_value = fallback(locale, key, options)
      return fallback_value if fallback_value && !fallback_value.respond_to?(:to_str)

      default = fallback_value || options.delete(:default)
      content = super(locale, key, options.update(:default => default))
      if content.respond_to?(:html_safe)
        content.html_safe
      else
        content
      end
    end

    # Returns locales availabile for this Copycopter project.
    # @return [Array<String>] available locales
    def available_locales
      sync.keys.map { |key| key.split('.').first }.uniq
    end

    private

    def lookup(locale, key, scope = [], options = {})
      parts = I18n.normalize_keys(locale, key, scope, options[:separator])
      key = parts.join('.')
      sync[key]
    end

    attr_reader :sync

    def fallback(locale, key, options)
      if @fallback
        @fallback.translate(locale, key, options)
      end
    rescue I18n::MissingTranslationData
      nil
    end

    def default(locale, object, subject, options = {})
      key = [locale, object].join(".")
      content = super(locale, object, subject, options)
      sync[key] = content.to_str if content.respond_to?(:to_str)
      content
    end
  end
end
