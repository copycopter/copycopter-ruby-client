require 'i18n'

module CopycopterClient
  class I18nBackend
    include I18n::Backend::Base

    def initialize(sync, options)
      @sync     = sync
      @public   = options[:public]
      @base_url = URI.parse("#{options[:protocol]}://#{options[:host]}:#{options[:port]}")
      @api_key  = options[:api_key]
    end

    def reload!
    end

    def translate(locale, key, options = {})
      content = super(locale, key, options)
      html = wrap_with_link_in_private(content, edit_url(locale, key))
      if html.respond_to?(:html_safe)
        html.html_safe
      else
        html
      end
    end

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
        sync[key] = options[:default]
        nil
      end
    end

    attr_reader :sync, :base_url, :api_key

    def public?
      @public
    end

    def edit_url(locale, key)
      base_url.merge("/edit/#{api_key}/#{locale}.#{key}").to_s
    end
  end
end
