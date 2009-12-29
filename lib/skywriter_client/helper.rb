require 'httparty'

module SkywriterClient
  # Helper methods for SkyWriter
  module Helper

    def sky_write(key, default=nil)
      SkywriterClient.sky_write(scope_key_by_partial(key), default)
    end
    alias_method :s, :sky_write

    private

    def scope_key_by_partial(key)
      if key.to_s.first == "."
        template.path_without_format_and_extension.gsub(%r{/_?}, ".") + key.to_s
      else
        key
      end
    end

  end
end
