require 'spec_helper'

describe CopyTunerClient do

  before do
    allow(CopyTunerClient.configuration).to receive_messages(cache: 'cache', client: 'client')
  end

  it 'delegates cache to the configuration object' do
    expect(CopyTunerClient.configuration).to receive(:cache).once
    expect(CopyTunerClient.cache).to eq('cache')
  end

  it 'delegates client to the configuration object' do
    expect(CopyTunerClient.configuration).to receive(:client).once
    expect(CopyTunerClient.client).to eq('client')
  end
end
