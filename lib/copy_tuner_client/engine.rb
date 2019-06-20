require 'copy_tuner_client/copyray'
require 'copy_tuner_client/translation_log'

module CopyTunerClient
  # Connects to integration points for Rails 3 applications
  class Engine < ::Rails::Engine
    initializer :initialize_copy_tuner_rails, :before => :load_config_initializers do |app|
      CopyTunerClient::Rails.initialize
    end

    initializer :initialize_copy_tuner_hook_methods, :after => :load_config_initializers do |app|
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::TranslationHelper.class_eval do
          def translate_with_copyray_comment(key, options = {})
            source = translate_without_copyray_comment(key, options)
            if !CopyTunerClient.configuration.disable_copyray_comment_injection && (options[:rescue_format] == :html || options[:rescue_format].nil?)
              separator = options[:separator] || I18n.default_separator
              scope = options[:scope]
              normalized_key =
                if key.to_s.first == '.'
                  scope_key_by_partial(key)
                else
                  I18n.normalize_keys(nil, key, scope, separator).join(separator)
                end
              CopyTunerClient::Copyray.augment_template(source, normalized_key)
            else
              source
            end
          end
          if CopyTunerClient.configuration.enable_middleware?
            alias_method :translate_without_copyray_comment, :translate
            alias_method :translate, :translate_with_copyray_comment
            alias :t :translate
            alias :tt :translate_without_copyray_comment
          else
            alias :tt :translate
          end
        end
      end

      if CopyTunerClient.configuration.enable_middleware?
        CopyTunerClient::TranslationLog.install_hook
      end

      require 'copy_tuner_client/simple_form_extention'
    end

    initializer "copy_tuner.assets.precompile", group: :all do |app|
      app.config.assets.precompile += ["copyray.js", "copyray.css"]
    end
  end
end
