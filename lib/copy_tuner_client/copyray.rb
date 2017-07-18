module CopyTunerClient
  class Copyray
    # This:
    #   message
    # Becomes:
    #   <!--COPYRAY views.home.index.message-->message
    def self.augment_template(source, key)
      augmented = if source.present?
                    "<!--COPYRAY #{key}-->#{source}"
                  else
                    source
                  end
      ActiveSupport::SafeBuffer === source ? ActiveSupport::SafeBuffer.new(augmented) : augmented
    end
  end
end
