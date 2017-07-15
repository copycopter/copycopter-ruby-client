module CopyTunerClient
  class Copyray
    # Returns augmented HTML where the source is simply wrapped in an HTML
    # comment with filepath info. Xray.js uses these comments to associate
    # elements with the templates that rendered them.
    #
    # This:
    #   <div class=".my-element">
    #     ...
    #   </div>
    #
    # Becomes:
    #   <!-- COPYRAY START 123 /path/to/file.html -->
    #   <div class=".my-element">
    #     ...
    #   </div>
    #   <!-- COPYRAY END 123 -->
    def self.augment_template(source, key)
      id = next_id
      # skim doesn't allow html comments, so use skim's comment syntax if it's skim
      augmented = if source.present?
                    "<!--COPYRAY START #{id} #{key} #{CopyTunerClient.configuration.project_url} -->#{source}<!--COPYRAY END #{id}-->"
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
