require 'spec_helper'

describe CopyTunerClient::RequestSync do
  let(:poller) { {} }
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { double('app', :call => response) }
  before do
    allow(cache).to receive_messages(:flush => nil, :download => nil)
    allow(poller).to receive(:start_sync).and_return(nil)
  end
  subject { CopyTunerClient::RequestSync.new(app, :poller => poller, :cache => cache, :interval => 0) }

  it "invokes the upstream app" do
    expect(app).to receive(:call).with(env)
    result = subject.call(env)
    expect(result).to eq(response)
  end
end

describe CopyTunerClient::RequestSync, 'serving assets' do
  let(:env) do
    { "PATH_INFO" => '/assets/choper.png' }
  end
  let(:poller) { {} }
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:app) { double('app', :call => response) }
  before do
    allow(cache).to receive_messages(:flush => nil, :download => nil)
    allow(poller).to receive(:start_sync).and_return(nil)
  end
  subject { CopyTunerClient::RequestSync.new(app, :poller => poller, :cache => cache, :interval => 0) }

  it "don't start sync" do
    expect(cache).to receive(:download).once
    subject.call(env)
    expect(poller).not_to receive(:start_sync)
    subject.call(env)
  end
end

describe CopyTunerClient::RequestSync do
  let(:poller) { {} }
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { double('app', :call => response) }
  subject { CopyTunerClient::RequestSync.new(app, :poller => poller, :cache => cache, :interval => 10) }
  before do
    allow(cache).to receive_messages(:flush => nil, :download => nil)
    allow(poller).to receive(:start_sync).and_return(nil)
  end

  context "first request" do
    it "download" do
      expect(cache).to receive(:download).once
      subject.call(env)
    end
  end

  context 'in interval request' do
    it "does not start sync for the second time" do
      expect(cache).to receive(:download).once
      subject.call(env)

      expect(poller).not_to receive(:start_sync)
      subject.call(env)
    end
  end

  context 'over interval request' do
    it "start sync for the second time" do
      expect(cache).to receive(:download).once
      subject.call(env)

      expect(poller).to receive(:start_sync).once
      subject.last_synced = Time.now - 60
      subject.call(env)
    end
  end
end
