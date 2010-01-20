require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase

  def setup
    reset_config
  end

  def build_client(opts = {})
    config = SkywriterClient::Configuration.new
    opts.each {|opt, value| config.send(:"#{opt}=", value) }
    SkywriterClient::Client.new(config)
  end

  should "default the open timeout to 2 seconds" do
  end

  should "default the read timeout to 5 seconds" do
  end

  should "allow override of the open timeout" do
  end

  should "allow override of the read timeout" do
  end

  should "connect to the right port for ssl" do
  end

  should "connect to the right port for non-ssl" do
  end

  should "use ssl if secure" do
  end

  should "not use ssl if not secure" do
  end

  should "be able to create a blurb for an environment" do
    reset_webmock
    stub_request(:post, /.*skywriterapp.*/).to_return(:status => 200, :body => "Posted to test.key")

    client = build_client(:api_key => '123')
    response = client.create(:environment => 'development', 
                             :key => 'test.key',
                             :content => 'content')

    assert_equal 200, response.code
    assert_requested :post, 
                     "http://skywriterapp.com/api/v1/environments/development/blurbs?",
                     :headers => { "X-API-KEY" => "123" },
                     :times => 1
  end

  should "be able to get a blurb for an environment" do
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "the content")

    client = build_client(:api_key => '123')
    response = client.get(:environment => 'development', :key => 'test.key')

    assert_equal 200, response.code
    assert_requested :get, 
                     "http://skywriterapp.com/api/v1/environments/development/blurbs/test.key?",
                     :headers => { "X-API-KEY" => "123" },
                     :times => 1
  end

  should "be able to get a blurb that doesn't exist for an environment" do
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    client = build_client(:api_key => '123')
    response = client.get(:environment => 'development', :key => 'test.key')

    assert_equal 404, response.code
    assert_requested :get, 
                     "http://skywriterapp.com/api/v1/environments/development/blurbs/test.key?",
                     :headers => { "X-API-KEY" => "123" },
                     :times => 1
  end
end
