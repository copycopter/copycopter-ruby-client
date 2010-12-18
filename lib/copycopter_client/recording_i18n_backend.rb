module CopycopterClient
  # I18n backend which passes translation off to an upstream backend and
  # records all keys that are translated within a block.
  #
  # This implementation is currently not safe for multithreaded environments.
  class RecordingI18nBackend
    include I18n::Backend::Base

    # @param upstream [I18n::Backend::Base] the upstream backend
    def initialize(upstream)
      @upstream = upstream
    end

    # Returns a list of keys translated during the block
    def record
      @recorded = []
      yield
      @recorded
    end

    # Reloads the upstream backend
    def reload!
      @upstream.reload!
    end

    # Returns available locales from the upstream backend
    def available_locales
      @upstream.available_locales
    end

    protected

    # Looks up a key and adds it to the list
    def lookup(locale, key, scope, options = {})
      normalized = I18n.normalize_keys(locale, key, scope, options[:separator])
      locale = normalized.shift
      @recorded |= [normalized.join('.')]
      @upstream.translate(locale, key, options)
    end
  end
end
