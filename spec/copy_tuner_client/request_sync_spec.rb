require 'spec_helper'

describe CopyTunerClient::RequestSync do
  let(:poller) { {} }
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { stub('app', :call => response) }
  before do
    cache.stubs(:flush => nil, :download => nil)
    poller.stubs(:start_sync => nil)
  end
  subject { CopyTunerClient::RequestSync.new(app, :poller => poller, :cache => cache, :interval => 0) }

  it "invokes the upstream app" do
    result = subject.call(env)
    expect(app).to have_received(:call).with(env)
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
  let(:app) { stub('app', :call => response) }
  before do
    cache.stubs(:flush => nil, :download => nil)
    poller.stubs(:start_sync => nil)
  end
  subject { CopyTunerClient::RequestSync.new(app, :poller => poller, :cache => cache, :interval => 0) }

  it "don't start sync" do
    subject.call(env)
    expect(cache).to have_received(:download).once
    subject.call(env)
    expect(poller).to have_received(:start_sync).never
  end
end

describe CopyTunerClient::RequestSync do
  let(:poller) { {} }
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { stub('app', :call => response) }
  subject { CopyTunerClient::RequestSync.new(app, :poller => poller, :cache => cache, :interval => 10) }
  before do
    cache.stubs(:flush => nil, :download => nil)
    poller.stubs(:start_sync => nil)
  end

  context "first request" do
    it "download" do
      subject.call(env)
      expect(cache).to have_received(:download).once
    end
  end

  context 'in interval request' do
    it "does not start sync for the second time" do
      subject.call(env)
      expect(cache).to have_received(:download).once
      subject.call(env)
      expect(poller).to have_received(:start_sync).never
    end
  end

  context 'over interval request' do
    it "start sync for the second time" do
      subject.call(env)
      expect(cache).to have_received(:download).once
      subject.last_synced = Time.now - 60
      subject.call(env)
      expect(poller).to have_received(:start_sync).once
    end
  end
end
