namespace :copycopter do
  desc "Notify Copycopter of a new deploy."
  task :deploy => :environment do
    CopycopterClient.deploy
    puts "Successfully marked all blurbs as published."
  end

  desc "Export Copycopter blurbs to yaml."
  task :export => :environment do
    CopycopterClient.cache.sync

    if yml = CopycopterClient.export
      PATH = "config/locales/copycopter.yml"
      File.new("#{Rails.root}/#{PATH}", 'w').write(yml)
      puts "Successfully exported blurbs to #{PATH}."
    else
      puts "No blurbs have been cached."
    end
  end
end
