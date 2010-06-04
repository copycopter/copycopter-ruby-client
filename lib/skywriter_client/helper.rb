module SkywriterClient
  # Helper methods for SkyWriter
  module Helper

    def sky_write(key, default=nil)
      result = SkywriterClient.sky_write(scope_key_by_partial(key), default)
      result = CGI.unescapeHTML(result.to_s)
      result
    end
    alias_method :s, :sky_write

    private

    def scope_key_by_partial(key)
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
