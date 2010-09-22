namespace :copycopter do
  desc "Notify Copycopter of a new deploy."
  task :deploy => :environment do
    require 'copycopter_tasks'
    CopycopterTasks.deploy(:to      => ENV['TO'],
                           :from    => ENV['FROM'],
                           :api_key => ENV['API_KEY'])
  end

  task :log_stdout do
    require 'logger'
    RAILS_DEFAULT_LOGGER = Logger.new(STDOUT)
  end
end
