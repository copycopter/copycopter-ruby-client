When "I generate a rails application" do
  steps %{
    When I run "rails _2.3.8_ testapp"
    And I cd to "testapp"
  }
end

When /^I configure the copycopter client with api key "([^"]*)"$/ do |api_key|
  steps %{
    When I run "ln -s #{PROJECT_ROOT} vendor/plugins/copycopter"
    And I write to "config/initializers/copycopter.rb" with:
      """
      CopycopterClient.configure do |config|
        config.api_key = "#{api_key}"
      end
      """
  }
end

When "I visit /$path" do |path|
  in_current_dir do
    require 'config/environment'
  end
  app = ActionController::Dispatcher.new
  request = Rack::MockRequest.new(app)
  response = request.get(path)
  @last_stdout = response.body
end

