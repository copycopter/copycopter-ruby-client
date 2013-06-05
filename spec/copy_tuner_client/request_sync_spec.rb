require 'spec_helper'

describe CopyTunerClient::RequestSync do

  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { stub('app', :call => response) }
  before { cache.stubs(:flush => nil, :download => nil) }
  subject { CopyTunerClient::RequestSync.new(app, :cache => cache, :interval => 0) }

  it "invokes the upstream app" do
    result = subject.call(env)
    app.should have_received(:call).with(env)
    result.should == response
  end

  it "flushes defaults" do
    subject.call(env)
    cache.should have_received(:flush)
  end

  it "downloads new copy" do
    subject.call(env)
    cache.should have_received(:download)
  end
end

describe CopyTunerClient::RequestSync, 'serving assets' do
  let(:env) do
    { "PATH_INFO" => '/assets/choper.png' }
  end
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:app) { stub('app', :call => response) }
  before { cache.stubs(:flush => nil, :download => nil) }
  subject { CopyTunerClient::RequestSync.new(app, :cache => cache, :interval => 0) }

  it "does not flush defaults" do
    subject.call(env)
    cache.should_not have_received(:flush)
  end
  it "does not download new copy" do
    subject.call(env)
    cache.should_not have_received(:download)
  end
end

describe CopyTunerClient::RequestSync do
  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { stub('app', :call => response) }
  before { cache.stubs(:flush => nil, :download => nil) }

  context 'in interval request' do
    subject { CopyTunerClient::RequestSync.new(app, :cache => cache, :interval => 10, :last_synced => Time.now) }
    it "does not flush defaults" do
      subject.call(env)
      cache.should_not have_received(:flush)
    end
    it "does not download new copy" do
      subject.call(env)
      cache.should_not have_received(:download)
    end
  end

  context 'over interval request' do
    subject { CopyTunerClient::RequestSync.new(app, :cache => cache, :interval => 10, :last_synced => Time.now - 60) }
    it "flushes defaults" do
      subject.call(env)
      cache.should have_received(:flush)
    end
    it "downloads new copy" do
      subject.call(env)
      cache.should have_received(:download)
    end
  end

  context "first request" do
    subject { CopyTunerClient::RequestSync.new(app, :cache => cache, :interval => 10) }
    it "flushes defaults" do
      subject.call(env)
      cache.should have_received(:flush)
    end
    it "downloads new copy" do
      subject.call(env)
      cache.should have_received(:download)
    end
  end
end
