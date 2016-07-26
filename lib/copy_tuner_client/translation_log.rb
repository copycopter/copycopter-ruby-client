module CopyTunerClient
  class TranslationLog
    def self.translations
      Thread.current[:translations] ||= {}
    end

    def self.clear
      Thread.current[:translations] = {}
    end

    def self.add(key, result)
      translations[key] = result unless translations.key? key
    end

    def self.install_hook
      I18n.class_eval do
        class << self
          def translate_with_copy_tuner_hook(*args)
            key = args[0]
            result = translate_without_copy_tuner_hook(*args)

            if key.is_a?(Array)
              key.zip(result).each { |k, v| CopyTunerClient::TranslationLog.add(k, v) unless v.is_a?(Array) }
            else
              CopyTunerClient::TranslationLog.add(key, result) unless result.is_a?(Array)
            end
            result
          end
          if CopyTunerClient.configuration.enable_middleware?
            alias_method_chain :translate, :copy_tuner_hook
            alias :t :translate
          end
        end
      end
    end
  end
end
