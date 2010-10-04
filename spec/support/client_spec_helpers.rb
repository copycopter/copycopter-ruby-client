module ClientSpecHelpers
  def reset_config
    CopycopterClient.configuration = nil
    CopycopterClient.configure do |config|
      config.api_key       = 'abc123'
      config.cache_enabled = false
    end
  end

  def stub_client
    stub('sender', :create => nil, :get => nil)
  end

  def stub_client!
    CopycopterClient.client = stub_client
  end
end

