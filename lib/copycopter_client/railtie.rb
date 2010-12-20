module CopycopterClient
  # Connects to integration points for Rails 3 applications
  class Railtie < ::Rails::Railtie
    initializer :initialize_copycopter_rails, :after => :before_initialize do
      CopycopterClient::Rails.initialize
    end

    rake_tasks do
      load "tasks/copycopter_client_tasks.rake"
    end
  end
end

