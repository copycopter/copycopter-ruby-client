require 'copy_tuner_client/copyray'
require 'copy_tuner_client/translation_log'

module CopyTunerClient
  # Connects to integration points for Rails 3 applications
  class Engine < ::Rails::Engine
    initializer :initialize_copy_tuner_rails, :before => :load_config_initializers do |app|
      CopyTunerClient::Rails.initialize

      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::TranslationHelper.class_eval do
          def translate_with_copyray_comment(key, options = {})
            source = translate_without_copyray_comment(key, options)
            if options[:rescue_format] == :html or options[:rescue_format].nil?
              CopyTunerClient::Copyray.augment_template(source, scope_key_by_partial(key))
            else
              source
            end
          end
          if CopyTunerClient.configuration.enable_middleware?
            alias_method_chain :translate, :copyray_comment
            alias :t :translate
            CopyTunerClient::TranslationLog.install_hook
          end
        end
      end
    end

    initializer "copy_tuner.assets.precompile", group: :all do |app|
      app.config.assets.precompile += ["copyray.js", "copyray.css"]
    end

    rake_tasks do
      load "tasks/copy_tuner_client_tasks.rake"
    end
  end
end
