module CopycopterClient
  # Helper methods for Copycopter
  module Helper

    def copy_for(key, default=nil)
      default = if default.respond_to?(:to_hash)
                  default[:default]
                else
                  default
                end

      result = CopycopterClient.copy_for(scope_copycopter_key_by_partial(key), default)
      result = CGI.unescapeHTML(result.to_s)
      result
    end
    alias_method :s, :copy_for

    private

    def scope_copycopter_key_by_partial(key)
      if key.to_s.first == "."
        if defined?(template)
          "#{template.path_without_format_and_extension.gsub(%r{/_?}, '.')}#{key}"
        else
          "#{controller_name}.#{action_name}#{key}"
        end
      else
        key
      end
    end

  end
end
