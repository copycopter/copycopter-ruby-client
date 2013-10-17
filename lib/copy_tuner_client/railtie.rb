module CopyTunerClient
  # Connects to integration points for Rails 3 applications
  class Railtie < ::Rails::Railtie
    initializer :initialize_copy_tuner_rails, :before => :load_config_initializers do |app|
      CopyTunerClient::Rails.initialize
      app.middleware_use CopyTunerClient::XrayMiddleware

      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::TranslationHelper.class_eval do
          def translate_with_copyray_comment(key, options = {})
            Rails.logger.info "------"
            translate_without_copyray_comment(key, options)
          end
          alias_method_chain :translate, :copyray_comment
        end
      end
    end

    rake_tasks do
      load "tasks/copy_tuner_client_tasks.rake"
    end
  end
end
