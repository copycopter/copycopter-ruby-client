if defined?(ActionController::Base)
  ActionController::Base.send :include, SkywriterClient::Helper
end
if defined?(ActionView::Base)
  ActionView::Base.send :include, SkywriterClient::Helper
end

SkywriterClient.configure(true) do |config|
  config.environment_name = RAILS_ENV
end
