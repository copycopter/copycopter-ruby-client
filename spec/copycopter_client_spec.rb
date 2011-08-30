require 'spec_helper'

describe CopycopterClient do

  before do
    CopycopterClient.configuration.stubs(:cache  => 'cache',
                                         :client => 'client')
  end

  it 'delegates cache to the configuration object' do
    CopycopterClient.cache.should == 'cache'
    CopycopterClient.configuration.should have_received(:cache).once
  end

  it 'delegates client to the configuration object' do
    CopycopterClient.client.should == 'client'
    CopycopterClient.configuration.should have_received(:client).once
  end
end
