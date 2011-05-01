class WritingCache
  def flush
    File.open(path, "w") do |file|
      file.write(object_id.to_s)
    end
  end

  def written?
    IO.read(path) == object_id.to_s
  end

  private

  def path
    File.join(PROJECT_ROOT, 'tmp', 'written_cache')
  end
end
