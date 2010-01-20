# Defines deploy:notify_skywriter which will send information about the deploy to Hoptoad.

Capistrano::Configuration.instance(:must_exist).load do
  after "deploy",            "deploy:notify_skywriter"
  after "deploy:migrations", "deploy:notify_skywriter"

  namespace :deploy do
    desc "Notify SkyWriter of the deployment"
    task :notify_skywriter, :except => { :no_release => true } do
      from_env = Rails.env
      rails_env = fetch(:skywriter_env, fetch(:rails_env, "production"))
      local_user = ENV['USER'] || ENV['USERNAME']
      executable = RUBY_PLATFORM.downcase.include?('mswin') ? 'rake.bat' : 'rake'
      notify_command = "#{executable} skywriter:deploy TO=#{rails_env} FROM=#{from_env}"
      notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
      puts "Notifying SkyWriter of Deploy (#{notify_command})"
      `#{notify_command}`
      puts "SkyWriter Notification Complete."
    end
  end
end
