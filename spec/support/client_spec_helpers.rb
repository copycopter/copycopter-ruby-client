module ClientSpecHelpers
  def reset_config
    CopycopterClient.configuration = nil
    CopycopterClient.configure(false) do |config|
      config.api_key = 'abc123'
    end
  end
end

