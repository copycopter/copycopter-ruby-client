namespace :copy_tuner do
  desc "Notify CopyTuner of a new deploy."
  task :deploy => :environment do
    CopyTunerClient.deploy
    puts "Successfully marked all blurbs as published."
  end

  desc "Export CopyTuner blurbs to yaml."
  task :export, %i[path] => :environment do |_, args|
    args.with_defaults(path: "config/locales/copy_tuner.yml")
    CopyTunerClient.cache.sync

    if yml = CopyTunerClient.export
      File.new("#{Rails.root}/#{args[:path]}", 'w').write(yml)
      puts "Successfully exported blurbs to #{args[:path]}."
    else
      raise "No blurbs have been cached."
    end
  end

  desc "Detect invalid keys."
  task :detect_conflict_keys => :environment do
    conflict_keys = CopyTunerClient::DottedHash.conflict_keys(CopyTunerClient.cache.blurbs)

    if conflict_keys.empty?
      puts 'All success'
    else
      pp conflict_keys
      raise 'Exists invalid keys'
    end
  end
end
