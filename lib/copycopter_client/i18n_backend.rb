module CopycopterClient
  class I18nBackend
    include I18n::Backend::Base

    def initialize(sync)
      @sync = sync
    end

    def reload!
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

    def available_locales
      sync.keys.map { |key| key.split('.').first }.uniq
    end

    private

    attr_reader :sync
  end
end
