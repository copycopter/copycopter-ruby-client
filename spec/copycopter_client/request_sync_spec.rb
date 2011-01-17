require 'spec_helper'

describe CopycopterClient::RequestSync do

  let(:sync) { {} }
  before { sync.stubs(:flush) }

  def build_request_sync(app)
    CopycopterClient::RequestSync.new(app, :sync => sync)
  end

  it "invokes the upstream app" do
    response = 'response'
    env = 'env'
    app = stub('app', :call => response)

    request_sync = build_request_sync(app)
    result = request_sync.call(env)

    app.should have_received(:call).with(env)
    result.should == response
    sync.should have_received(:flush)
  end
end
