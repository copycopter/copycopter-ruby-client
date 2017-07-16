module CopyTunerClient
  class Copyray
    # This:
    #   message
    # Becomes:
    #   <span data-copyray-key="views.home.index.message">message</span>
    def self.augment_template(source, key)
      augmented = if source.present?
                    "<span data-copyray-key='#{key}'>#{source}</span>"
                  else
                    source
                  end
      ActiveSupport::SafeBuffer === source ? ActiveSupport::SafeBuffer.new(augmented) : augmented
    end
  end
end
