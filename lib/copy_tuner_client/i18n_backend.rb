require 'i18n'
require 'copy_tuner_client/configuration'

module CopyTunerClient
  # I18n implementation designed to synchronize with CopyTuner.
  #
  # Expects an object that acts like a Hash, responding to +[]+, +[]=+, and +keys+.
  #
  # This backend will be used as the default I18n backend when the client is
  # configured, so you will not need to instantiate this class from the
  # application. Instead, just use methods on the I18n class.
  #
  # This implementation will also load translations from locale files.
  class I18nBackend
    include I18n::Backend::Simple::Implementation

    # Usually instantiated when {Configuration#apply} is invoked.
    # @param cache [Cache] must act like a hash, returning and accept blurbs by key.
    def initialize(cache)
      @cache = cache
    end

    # Translates the given local and key. See the I18n API documentation for details.
    #
    # @return [Object] the translated key (usually a String)
    def translate(locale, key, options = {})
      content = super(locale, key, options)
      if CopyTunerClient.configuration.inline_translation
        content = (content.is_a?(Array) ? content : key.to_s)
      end

      if !CopyTunerClient.configuration.html_escape
        # Backward compatible
        content.respond_to?(:html_safe) ? content.html_safe : content
      else
        content
      end
    end

    # Returns locales availabile for this CopyTuner project.
    # @return [Array<String>] available locales
    def available_locales
      return @available_locales if defined?(@available_locales)
      cached_locales = cache.keys.map { |key| key.split('.').first }
      @available_locales = (cached_locales + super).uniq.map { |locale| locale.to_sym }
    end

    # Stores the given translations.
    #
    # Updates will be visible in the current process immediately, and will
    # propagate to CopyTuner during the next flush.
    #
    # @param [String] locale the locale (ie "en") to store translations for
    # @param [Hash] data nested key-value pairs to be added as blurbs
    # @param [Hash] options unused part of the I18n API
    def store_translations(locale, data, options = {})
      super
      store_item(locale, data)
    end

    private

    def lookup(locale, key, scope = [], options = {})
      return nil if !key.is_a?(String) && !key.is_a?(Symbol)

      parts = I18n.normalize_keys(locale, key, scope, options[:separator])
      key_with_locale = parts.join('.')
      content = cache[key_with_locale] || super
      cache[key_with_locale] = nil if content.nil?
      content
    end

    def store_item(locale, data, scope = [])
      if data.respond_to?(:to_hash)
        data.to_hash.each do |key, value|
          store_item(locale, value, scope + [key])
        end
      elsif data.respond_to?(:to_str)
        key = ([locale] + scope).join('.')
        cache[key] = data.to_str
      end
    end

    def load_translations(*filenames)
      super
      cache.wait_for_download
    end

    def default(locale, object, subject, options = {})
      content = super(locale, object, subject, options)
      return content if !object.is_a?(String) && !object.is_a?(Symbol)

      if content.respond_to?(:to_str)
        parts = I18n.normalize_keys(locale, object, options[:scope], options[:separator])
        # NOTE: ActionView::Helpers::TranslationHelper#translate wraps default String in an Array
        if subject.is_a?(String) || (subject.is_a?(Array) && subject.size == 1 && subject.first.is_a?(String))
          key = parts.join('.')
          cache[key] = content.to_str
        end
      end
      content
    end

    attr_reader :cache
  end
end
