require 'copy_tuner_client/copyray_middleware'
require 'copy_tuner_client/copyray'

module CopyTunerClient
  # Connects to integration points for Rails 3 applications
  class Engine < ::Rails::Engine
    initializer :initialize_copy_tuner_rails, :before => :load_config_initializers do |app|
      CopyTunerClient::Rails.initialize
      app.middleware.use CopyTunerClient::CopyrayMiddleware

      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::TranslationHelper.class_eval do
          def translate_with_copyray_comment(key, options = {})
            source = translate_without_copyray_comment(key, options)
            CopyTunerClient::Copyray.augment_template(source, scope_key_by_partial(key))
          end
          alias_method_chain :translate, :copyray_comment
          alias t translate
        end
      end
    end

    rake_tasks do
      load "tasks/copy_tuner_client_tasks.rake"
    end
  end
end
