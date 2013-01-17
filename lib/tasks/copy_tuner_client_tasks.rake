namespace :copy_tuner do
  desc "Notify CopyTuner of a new deploy."
  task :deploy => :environment do
    CopyTunerClient.deploy
    puts "Successfully marked all blurbs as published."
  end

  desc "Export CopyTuner blurbs to yaml."
  task :export => :environment do
    CopyTunerClient.cache.sync

    if yml = CopyTunerClient.export
      PATH = "config/locales/copy_tuner.yml"
      File.new("#{Rails.root}/#{PATH}", 'w').write(yml)
      puts "Successfully exported blurbs to #{PATH}."
    else
      puts "No blurbs have been cached."
    end
  end
end
