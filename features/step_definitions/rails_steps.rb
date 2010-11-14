When "I generate a rails application" do
  if Rails::VERSION::MAJOR == 3
    subcommand = 'new'
  else
    subcommand = ''
  end

  steps %{
    When I run "rails _#{Rails::VERSION::STRING}_ #{subcommand} testapp"
    And I cd to "testapp"
  }
end

When /^I configure the copycopter client with api key "([^"]*)"$/ do |api_key|
  steps %{
    When I run "rm -f vendor/plugins/copycopter"
    And I run "ln -s #{PROJECT_ROOT} vendor/plugins/copycopter"
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
  @last_response = RailsServer.get(path)
end

When /^I configure the copycopter client to used published data$/ do
  in_current_dir do
    config_path = "config/initializers/copycopter.rb"
    contents = IO.read(config_path)
    contents.sub!("end", "  config.development_environments = []\nend")
    File.open(config_path, "w") { |file| file.write(contents) }
  end
end

Then /^the copycopter client version and environment should have been logged$/ do
  client_version = CopycopterClient::VERSION
  environment_info = "[Ruby: #{RUBY_VERSION}]"
  environment_info << " [Rails: #{Rails::VERSION::STRING}]"
  environment_info << " [Env: development]"
  steps %{
    Then the log should contain "Client #{client_version} ready"
    Then the log should contain "Environment Info: #{environment_info}"
  }
end

Then /^the log should contain "([^"]*)"$/ do |line|
  prefix = "** [Copycopter] "
  pattern = Regexp.compile([Regexp.escape(prefix), Regexp.escape(line)].join(".*"))
  log_path = "log/development.log"
  in_current_dir do
    File.open(log_path) do |file|
      unless file.readlines.any? { |file_line| file_line =~ pattern }
        raise "In log file:\n#{IO.read(log_path)}\n\nMissing line:\n#{pattern}"
      end
    end
  end
end

When /^I successfully rake "([^"]*)"$/ do |task|
  in_current_dir do
    pid = fork do
      load('Rakefile')
      Rake::Task[task].invoke
    end
    Process.wait(pid)
    unless $?.exitstatus == 0
      raise "rake task exited with status #{$?.exitstatus}"
    end
  end
end

Then /^the response should contain "([^"]+)"$/ do |text|
  @last_response.should include(text)
end

After do
  RailsServer.stop
end
