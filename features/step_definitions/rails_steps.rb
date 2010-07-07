When /^I save the following as "([^\"]*)"$/ do |path, string|
  FileUtils.mkdir_p(File.join(CUC_RAILS_ROOT, File.dirname(path)))
  File.open(File.join(CUC_RAILS_ROOT, path), 'w') { |file| file.write(string) }
end

When "the rails app is running" do
  ShamRack.at("example.com").rackup do
    Dir.chdir(CUC_RAILS_ROOT)
    ENV['RAILS_ENV'] = 'production'
    require "config/environment"
    use Rails::Rack::LogTailer
    run ActionController::Dispatcher.new 
  end
end

When "this plugin is available" do
  $LOAD_PATH << "#{PROJECT_ROOT}/lib"
  require 'skywriter_client'
  When %{I save the following as "vendor/plugins/skywriter_client/rails/init.rb"},
       IO.read("#{PROJECT_ROOT}/rails/init.rb") 

  ShamRack.at("skywriterapp.com").sinatra do
    get "/api/v1/environments/:env/blurbs/:blurb" do |env, blurb|
      "e:#{env} b:#{blurb}"
    end
  end
end
