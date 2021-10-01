module CopyTunerClient
  module HelperExtension
    class << self
      def hook_translation_helper(mod, middleware_enabled:)
        mod.class_eval do
          def translate_with_copyray_comment(key, **options)
            source = translate_without_copyray_comment(key, **options)
            # TODO: 0.6.0以降で options[:rescue_format] == text を消す
            if CopyTunerClient.configuration.disable_copyray_comment_injection || options[:rescue_format] == :text
              if options[:rescue_format] == :text
                ActiveSupport::Deprecation.warn('rescue_format option is deprecated in copy_tuner_client@0.6.0')
              end
              source
            else
              separator = options[:separator] || I18n.default_separator
              scope = options[:scope]
              normalized_key =
                if key.to_s.first == '.'
                  scope_key_by_partial(key)
                else
                  I18n.normalize_keys(nil, key, scope, separator).join(separator)
                end
              CopyTunerClient::Copyray.augment_template(source, normalized_key)
            end
          end
          if middleware_enabled
            alias_method :translate_without_copyray_comment, :translate
            alias_method :translate, :translate_with_copyray_comment
            alias :t :translate
            alias :tt :translate_without_copyray_comment
          else
            alias :tt :translate
          end
        end
      end
    end
  end
end
