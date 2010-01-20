namespace :skywriter do
  desc "Notify Skywriter of a new deploy."
  task :deploy => :environment do
    require 'skywriter_tasks'
    SkywriterTasks.deploy(:to      => ENV['TO'],
                          :from    => ENV['FROM'],
                          :api_key => ENV['API_KEY'])
  end

  task :log_stdout do
    require 'logger'
    RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
  end
end
