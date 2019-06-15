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
    keys = Set.new
    invalid_keys = Hash.new {[]}

    CopyTunerClient.keys.sort.each do |key|
      parts = key.split('.').inject([]) do |memo, k|
        memo << (memo.present? ? [memo.last, k].join('.') : k)
      end

      already_key = parts.find { |k| keys.member?(k) }
      if already_key.present?
        invalid_keys[already_key] = invalid_keys[already_key].push(key)
        next
      end

      keys.add(key)
    end

    if invalid_keys.length > 0
      pp invalid_keys
      raise 'Exists invalid keys'
    else
      puts 'All success'
    end
  end
end
