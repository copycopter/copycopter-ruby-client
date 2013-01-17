module ClientSpecHelpers
  def reset_config
    CopyTunerClient.configuration = nil
    CopyTunerClient.configure(false) do |config|
      config.api_key = 'abc123'
    end
  end
end
