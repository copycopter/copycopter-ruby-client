require 'copy_tuner_client/copyray'
require 'copy_tuner_client/translation_log'
require 'copy_tuner_client/helper_extension'

module CopyTunerClient
  # Connects to integration points for Rails 3 applications
  class Engine < ::Rails::Engine
    initializer :initialize_copy_tuner_rails, :before => :load_config_initializers do |app|
      CopyTunerClient::Rails.initialize
    end

    initializer :initialize_copy_tuner_hook_methods, :after => :load_config_initializers do |app|
      ActiveSupport.on_load(:action_view) do
        CopyTunerClient::HelperExtension.hook_translation_helper(
          ActionView::Helpers::TranslationHelper, 
          middleware_enabled: CopyTunerClient.configuration.enable_middleware?
        )
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
