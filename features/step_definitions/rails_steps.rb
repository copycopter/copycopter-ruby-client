When /^I generate a new rails application$/ do
  Dir.chdir(TEMP_ROOT)
  `rails _2.3.8_ #{APP_NAME}`
end

When /^I save the following as "([^\"]*)"$/ do |path, string|
  FileUtils.mkdir_p(File.join(CUC_RAILS_ROOT, File.dirname(path)))
  File.open(File.join(CUC_RAILS_ROOT, path), 'w') { |file| file.write(string) }
end

When "the rails app is running" do
  ShamRack.at("example.com").rackup do
    Dir.chdir(CUC_RAILS_ROOT)
    require "config/environment"
    use Rails::Rack::LogTailer
    run ActionController::Dispatcher.new 
  end
end

When "skywriter is available" do
  ShamRack.at("skywriter.local").sinatra do
    get "/api/v1/environments/:env/blurbs/:blurb" do |env, blurb|
      "e:#{env} b:#{blurb}"
    end
  end
end

When "this plugin is available" do
  $LOAD_PATH << "#{PROJECT_ROOT}/lib"
  require 'skywriter_client'
  init = IO.read("#{PROJECT_ROOT}/rails/init.rb")
  When %{I save the following as "vendor/plugins/skywriter_client/rails/init.rb"}, init
end
