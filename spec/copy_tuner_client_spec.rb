require 'spec_helper'

describe CopyTunerClient do

  before do
    CopyTunerClient.configuration.stubs(:cache  => 'cache',
                                         :client => 'client')
  end

  it 'delegates cache to the configuration object' do
    expect(CopyTunerClient.cache).to eq('cache')
    expect(CopyTunerClient.configuration).to have_received(:cache).once
  end

  it 'delegates client to the configuration object' do
    expect(CopyTunerClient.client).to eq('client')
    expect(CopyTunerClient.configuration).to have_received(:client).once
  end
end
