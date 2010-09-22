# Defines deploy:notify_copycopter which will send information about the deploy to copycopter.

Capistrano::Configuration.instance(:must_exist).load do
  after "deploy",            "deploy:notify_copycopter"
  after "deploy:migrations", "deploy:notify_copycopter"

  namespace :deploy do
    desc "Notify Copycopter of the deployment"
    task :notify_copycopter, :except => { :no_release => true } do
      from_env = Rails.env
      rails_env = fetch(:copycopter_env, fetch(:rails_env, "production"))
      local_user = ENV['USER'] || ENV['USERNAME']
      executable = RUBY_PLATFORM.downcase.include?('mswin') ? 'rake.bat' : 'rake'
      notify_command = "#{executable} copycopter:deploy TO=#{rails_env} FROM=#{from_env}"
      notify_command << " API_KEY=#{ENV['API_KEY']}" if ENV['API_KEY']
      puts "Notifying Copycopter of Deploy (#{notify_command})"
      `#{notify_command}`
      puts "Copycopter Notification Complete."
    end
  end
end
