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
        config.polling_delay = 1
      end
      """
  }
end

When "I start the application" do
  in_current_dir do
    RailsServer.start(ENV['RAILS_PORT'])
  end
end

When "I visit /$path" do |path|
  @last_stdout = RailsServer.get(path)
end

When /^I configure the copycopter client to used published data$/ do
  in_current_dir do
    config_path = "config/initializers/copycopter.rb"
    contents = IO.read(config_path)
    contents.sub!("end", "  config.development_environments = []\nend")
    File.open(config_path, "w") { |file| file.write(contents) }
  end
end

After do
  RailsServer.stop
end
