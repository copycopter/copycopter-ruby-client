if defined?(ActionController::Base)
  ActionController::Base.send :include, CopycopterClient::Helper
end
if defined?(ActionView::Base)
  ActionView::Base.send :include, CopycopterClient::Helper
end

require 'copycopter_client'

CopycopterClient.configure(false) do |config|
  config.environment_name = Rails.env
  config.logger           = Rails.logger
  config.framework        = "Rails: #{Rails::VERSION::STRING}"
end

