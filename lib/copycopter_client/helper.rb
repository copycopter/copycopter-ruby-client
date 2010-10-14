module CopycopterClient
  # Helper methods for Copycopter
  # @deprecated use +I81n#translate+ instead.
  module Helper
    # Returns copy for the given key in the current locale.
    # @param key [String] the key you want copy for
    # @param default [String, Hash] an optional default value, used if this key is missing
    # @option default [String] :default the default text
    def copy_for(key, default=nil)
      default = if default.respond_to?(:to_hash)
                  default[:default]
                else
                  default
                end

      key = scope_copycopter_key_by_partial(key)
      warn("WARNING: #s is deprecated; use t(#{key.inspect}, :default => #{default.inspect}) instead.")
      I18n.translate(key, { :default => default })
    end
    alias_method :s, :copy_for

    private

    def scope_copycopter_key_by_partial(key)
      if respond_to?(:scope_key_by_partial, true)
        scope_key_by_partial(key)
      elsif key.to_s[0].chr == "."
        if respond_to?(:template)
          "#{template.path_without_format_and_extension.gsub(%r{/_?}, '.')}#{key}"
        else
          "#{controller_name}.#{action_name}#{key}"
        end
      else
        key
      end
    end
  end

  extend Helper
end
