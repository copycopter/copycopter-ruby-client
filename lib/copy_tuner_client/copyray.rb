module CopyTunerClient
  class Copyray
    # This:
    #   message
    #
    # Becomes:
    #   <span data-copyray-id="123" data-copyray-key="views.home.index.message">message</span>
    def self.augment_template(source, key)
      id = next_id
      # skim doesn't allow html comments, so use skim's comment syntax if it's skim
      augmented = if source.present?
                    "<span data-copyray-key='#{key}'>#{source}</span>"
                  else
                    source
                  end
      ActiveSupport::SafeBuffer === source ? ActiveSupport::SafeBuffer.new(augmented) : augmented
    end

    def self.next_id
      @id = (@id ||= 0) + 1
    end
  end
end
