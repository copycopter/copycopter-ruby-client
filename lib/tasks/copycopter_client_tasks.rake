namespace :copycopter do
  desc "Notify Copycopter of a new deploy."
  task :deploy => :environment do
    debugger
    CopycopterClient.deploy
    puts "Successfully marked all blurbs as published."
  end
end
