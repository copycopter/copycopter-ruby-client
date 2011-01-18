require 'spec_helper'

describe CopycopterClient::RequestSync do

  let(:sync) { {} }
  let(:response) { 'response' }
  let(:env) { 'env' }
  let(:app) { stub('app', :call => response) }
  before { sync.stubs(:flush => nil, :download => nil) }
  subject { CopycopterClient::RequestSync.new(app, :sync => sync) }

  it "invokes the upstream app" do
    result = subject.call(env)
    app.should have_received(:call).with(env)
    result.should == response
  end

  it "flushes defaults" do
    subject.call(env)
    sync.should have_received(:flush)
  end

  it "downloads new copy" do
    subject.call(env)
    sync.should have_received(:download)
  end
end
