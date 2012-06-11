namespace :copycopter do
  desc "Notify Copycopter of a new deploy."
  task :deploy => :environment do
    CopycopterClient.deploy
    puts "Successfully marked all blurbs as published."
  end

  desc "Export Copycopter blurbs to yaml. Optionally set CC_EXPORT_PATH to the output path"
  task :export => :environment do
    CopycopterClient.cache.sync

    if yml = CopycopterClient.export
      PATH = ENV['CC_EXPORT_PATH'] ? ENV['CC_EXPORT_PATH'] : "config/locales/copycopter.yml"
      File.new("#{Bundler.root}/#{PATH}", 'w').write(yml)
      puts "Successfully exported blurbs to #{PATH}."
    else
      puts "No blurbs have been cached."
    end
  end
end
