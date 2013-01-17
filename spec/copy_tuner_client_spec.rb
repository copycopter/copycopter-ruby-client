require 'spec_helper'

describe CopyTunerClient do

  before do
    CopyTunerClient.configuration.stubs(:cache  => 'cache',
                                         :client => 'client')
  end

  it 'delegates cache to the configuration object' do
    CopyTunerClient.cache.should == 'cache'
    CopyTunerClient.configuration.should have_received(:cache).once
  end

  it 'delegates client to the configuration object' do
    CopyTunerClient.client.should == 'client'
    CopyTunerClient.configuration.should have_received(:client).once
  end
end
