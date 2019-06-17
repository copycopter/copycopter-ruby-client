namespace :copy_tuner do
  desc "Notify CopyTuner of a new deploy."
  task :deploy => :environment do
    CopyTunerClient.deploy
    puts "Successfully marked all blurbs as published."
  end

  desc "Export CopyTuner blurbs to yaml."
  task :export, [:file_name] => :environment do |_, args|
    args.with_defaults(file_name: 'copy_tuner.yml')

    CopyTunerClient.cache.sync

    if yml = CopyTunerClient.export
      path = Rails.root.join('config', 'locales', args[:file_name])
      File.new(path, 'w').write(yml)
      puts "Successfully exported blurbs to #{path}."
    else
      raise "No blurbs have been cached."
    end
  end

  desc "Detect invalid keys."
  task :detect_invalid_keys => :environment do
    all_keys = CopyTunerClient.keys
    results = Hash.new {[]}

    all_keys.sort.each do |key|
      invalid_keys = all_keys.find_all { |k| k.start_with?("#{key}.") }
      if invalid_keys.present?
        results[key] = invalid_keys
      end
    end

    if results.empty?
      puts 'All success'
    else
      pp results
      raise 'Exists invalid keys'
    end
  end
end
