When "I generate a rails application" do
  if Rails::VERSION::MAJOR == 3
    subcommand = 'new'
    if Rails::VERSION::MINOR == 0
      options = ''
    else
      options = '--skip-bundle'
    end
  else
    subcommand = ''
    options = ''
  end

  run_simple("rails _#{Rails::VERSION::STRING}_ #{subcommand} testapp #{options}")
  cd("testapp")

  if Rails::VERSION::MAJOR == 3
    append_to_file("Gemfile", <<-GEMS)
      gem "thin"
      gem "sham_rack"
      gem "sinatra"
      gem "json"
    GEMS
    run_simple("bundle install --local")

    When %{I remove lines containing "rjs" from "config/environments/development.rb"}
  end
end

When /^I configure the copycopter client with api key "([^"]*)"$/ do |api_key|
  write_file("config/initializers/copycopter.rb", <<-RUBY)
    CopycopterClient.configure do |config|
      config.api_key = "#{api_key}"
      config.polling_delay = 1
      config.host = 'localhost'
      config.secure = false
      config.port = #{FakeCopycopterApp.port}
    end
  RUBY

  if Rails::VERSION::MAJOR == 3
    append_to_file("Gemfile", <<-GEMS)
      gem "copycopter_client", :path => "../../.."
    GEMS
  else
    in_current_dir { FileUtils.rm_f("vendor/plugins/copycopter") }
    run_simple("ln -s #{PROJECT_ROOT} vendor/plugins/copycopter")
  end
end

When "I start the application" do
  in_current_dir do
    RailsServer.start(ENV['RAILS_PORT'], @announce_stderr)
  end
end

When /^I start the application in the "([^"]+)" environment$/ do |environment|
  in_current_dir do
    old_environment = ENV['RAILS_ENV']
    begin
      ENV['RAILS_ENV'] = environment
      RailsServer.start(ENV['RAILS_PORT'], @announce_stderr)
    ensure
      ENV['RAILS_ENV'] = old_environment
    end
  end
end

When /^I visit (\/.*)$/ do |path|
  @last_response = RailsServer.get(path)
end

When /^I configure the copycopter client to use published data$/ do
  in_current_dir do
    config_path = "config/initializers/copycopter.rb"
    contents = IO.read(config_path)
    contents.sub!("end", "  config.development_environments = []\nend")
    File.open(config_path, "w") { |file| file.write(contents) }
  end
end

When /^I configure the copycopter client to have a polling delay of (\d+) seconds$/ do |polling_delay|
  in_current_dir do
    config_path = "config/initializers/copycopter.rb"
    contents = IO.read(config_path)
    contents.sub!(/config.polling_delay = .+/, "config.polling_delay = #{polling_delay}")
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

Then /^the log should not contain "([^"]*)"$/ do |line|
  log_path = "log/development.log"
  in_current_dir do
    File.open(log_path) do |file|
      if bad_line = file.readlines.detect { |file_line| file_line.include?(line) }
        raise "In log file:\n#{log_path}\n\nGot unexpected line:\n#{bad_line}"
      end
    end
  end
end

When /^I successfully rake "([^"]*)"$/ do |task|
  run_simple("rake #{task}")
end

Then /^the response should contain "([^"]+)"$/ do |text|
  @last_response.body.should include(text)
end

When /^I route the "([^"]+)" resource$/ do |resource|
  if Rails::VERSION::MAJOR == 3
    draw = "Testapp::Application.routes.draw do\n"
  else
    draw = "ActionController::Routing::Routes.draw do |map|\nmap."
  end

  routes = "#{draw}resources :#{resource}\nend"

  overwrite_file("config/routes.rb", routes)
end

When /^I run a short lived process that sets the key "([^"]*)" to "([^"]*)"$/ do |key, value|
  if Rails::VERSION::MAJOR == 3
    run_simple %[script/rails runner 'I18n.translate("#{key}", :default => "#{value}")']
  else
    run_simple %[script/runner 'I18n.translate("#{key}", :default => "#{value}")']
  end
end

When /^I remove lines containing "([^"]*)" from "([^"]*)"$/ do |content, filename|
  in_current_dir do
    result = ""
    File.open(filename, "r") do |file|
      file.each_line do |line|
        result << line unless line.include?(content)
      end
    end

    File.open(filename, "w") do |file|
      file.write(result)
    end
  end
end


After do
  RailsServer.stop
end
