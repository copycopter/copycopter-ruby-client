if defined?(ActionController::Base)
  ActionController::Base.send :include, CopycopterClient::Helper
end
if defined?(ActionView::Base)
  ActionView::Base.send :include, CopycopterClient::Helper
end

CopycopterClient.configure(false) do |config|
  config.environment_name = RAILS_ENV
end

