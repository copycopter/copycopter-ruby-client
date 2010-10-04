require 'spec_helper'

describe CopycopterClient do
  before { reset_config }

  def build_client(opts = {})
    config = CopycopterClient::Configuration.new
    opts.each {|opt, value| config.send(:"#{opt}=", value) }
    CopycopterClient::Client.new(config)
  end

  it "should default the open timeout to 2 seconds" do
  end

  it "should default the read timeout to 5 seconds" do
  end

  it "should allow override of the open timeout" do
  end

  it "should allow override of the read timeout" do
  end

  it "should connect to the right port for ssl" do
  end

  it "should connect to the right port for non-ssl" do
  end

  it "should use ssl if secure" do
  end

  it "should not use ssl if not secure" do
  end

  it "should be able to create a blurb for an environment" do
    reset_webmock
    stub_request(:post, /.*copycopter.*/).to_return(:status => 200, :body => "Posted to test.key")

    client = build_client(:api_key => '123')
    response = client.create(:environment => 'development',
                             :key => 'test.key',
                             :content => 'content')

    response.code.should == 200
    url = "http://copycopter.com/api/v1/environments/development/blurbs"
    WebMock.should have_requested(:post, url).
      with(:headers => { "X-API-KEY" => "123" }).
      once
  end

  it "should be able to get a blurb for an environment" do
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "the content")

    client = build_client(:api_key => '123')
    response = client.get(:environment => 'development', :key => 'test.key')

    response.code.should == 200
    url = "http://copycopter.com/api/v1/environments/development/blurbs/test.key"
    WebMock.should have_requested(:get, url).
      with(:headers => { "X-API-KEY" => "123" }).
      once
  end

  it "should be able to get a blurb that doesn't exist for an environment" do
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    client = build_client(:api_key => '123')
    response = client.get(:environment => 'development', :key => 'test.key')

    response.code.should == 404
    url = "http://copycopter.com/api/v1/environments/development/blurbs/test.key"
    WebMock.should have_requested(:get, url).
      with(:headers => { "X-API-KEY" => "123" }).
      once
  end
end

