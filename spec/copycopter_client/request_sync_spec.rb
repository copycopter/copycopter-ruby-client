require 'spec_helper'

describe CopycopterClient::RequestSync do

  let(:cache) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { stub('app', :call => response) }
  before { cache.stubs(:flush => nil, :download => nil) }
  subject { CopycopterClient::RequestSync.new(app, :cache => cache) }

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
