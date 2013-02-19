module CopyTunerClient
  # Connects to integration points for Rails 3 applications
  class Railtie < ::Rails::Railtie
    initializer :initialize_copy_tuner_rails, :before => :load_config_initializers do
      CopyTunerClient::Rails.initialize
    end

    rake_tasks do
      load "tasks/copy_tuner_client_tasks.rake"
    end
  end
end
