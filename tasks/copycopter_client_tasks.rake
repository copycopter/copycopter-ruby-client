namespace :copycopter do
  desc "Notify Copycopter of a new deploy."
  task :deploy => :environment do
    CopycopterClient.deploy
  end
end
