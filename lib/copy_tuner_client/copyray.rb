module CopyTunerClient
  class Copyray
    # This:
    #   message
    # Becomes:
    #   <!--COPYRAY views.home.index.message-->message
    def self.augment_template(source, key)
      augmented = if source.present?
                    escape = CopyTunerClient.configuration.html_escape && !key.end_with?('_html', '.html')
                    "<!--COPYRAY #{key}-->#{escape ? ERB::Util.html_escape(source) : source}"
                  else
                    source
                  end
      augmented.html_safe
    end
  end
end
