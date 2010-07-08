Given "I generate a rails application" do
  FileUtils.rm_rf TEMP_ROOT
  FileUtils.mkdir_p TEMP_ROOT
  Dir.chdir(TEMP_ROOT) do
    `rails _2.3.8_ #{APP_NAME}`
  end
end

When 'I save the following as "$path"' do |path, string|
  FileUtils.mkdir_p(File.join(CUC_RAILS_ROOT, File.dirname(path)))
  File.open(File.join(CUC_RAILS_ROOT, path), 'w') { |file| file.write(string) }
end

When "the rails app is running" do
  ShamRack.at("example.com").rackup do
    Dir.chdir(CUC_RAILS_ROOT)
    require "config/environment"
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
      if blurb =~ /404/
        raise Sinatra::NotFound
      else
        "e:#{env} b:#{blurb}"
      end
    end
  end
end

When "I visit and print /$path" do |path|
  When %{I visit /#{path}}
  puts @response_body
end

When "I visit /$path" do |path|
  @response_body = Net::HTTP.get(URI.parse("http://example.com/#{path}"))

  if defined?(ActionController) && ActionController::Reloader.default_lock
    ActionController::Reloader.default_lock.unlock
  end
end

Then 'I should see "$something"' do |something|
  assert_match something, @response_body
end

