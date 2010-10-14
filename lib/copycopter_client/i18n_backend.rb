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
    # @option options [Boolean] :public when +true+, edit links will not be inserted.
    # @option options [String] :protocol the protocol to use for edit links
    # @option options [String] :host the host to use for edit links
    # @option options [Fixnum] :port the port to use for edit links
    # @option options [String] :api_key the api key to use in edit links
    # @option options [I18n::Backend::Base] :fallback_backend I18n backend where missing translations can be found
    def initialize(sync, options)
      @sync     = sync
      @public   = options[:public]
      @base_url = URI.parse("#{options[:protocol]}://#{options[:host]}:#{options[:port]}")
      @api_key  = options[:api_key]
      @fallback = options[:fallback_backend]
    end

    # This is invoked by frameworks when locales should be loaded. The
    # Copycopter client loads content in the background, so this method waits
    # until the first download is complete.
    def reload!
      sync.wait_for_download
    end

    # Translates the given local and key. See the I81n API documentation for details.
    # @return [String] the translated key
    def translate(locale, key, options = {})
      content = super(locale, key, options)
      html = wrap_with_link_in_private(content, edit_url(locale, key))
      if html.respond_to?(:html_safe)
        html.html_safe
      else
        html
      end
    end

    # Returns locales availabile for this Copycopter project.
    # @return [Array<String>] available locales
    def available_locales
      sync.keys.map { |key| key.split('.').first }.uniq
    end

    private

    def wrap_with_link_in_private(content, url)
      if public?
        content
      else
        %{#{content} <a href="#{url}" target="_blank">Edit</a>}
      end
    end

    def lookup(locale, key, scope = [], options = {})
      parts = I18n.normalize_keys(locale, key, scope, options[:separator])
      key = parts.join('.')
      if content = sync[key]
        content
      else
        parts.shift
        sync[key] = fallback(locale, parts.join('.'), options) || options[:default]
      end
    end

    attr_reader :sync, :base_url, :api_key

    def public?
      @public
    end

    def edit_url(locale, key)
      base_url.merge("/edit/#{api_key}/#{locale}.#{key}").to_s
    end

    def fallback(locale, key, options)
      @fallback.translate(locale, key, options) if @fallback
    end
  end
end
