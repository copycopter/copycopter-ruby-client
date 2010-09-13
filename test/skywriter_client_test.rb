require File.dirname(__FILE__) + '/helper'

class SkywriterclientTest < Test::Unit::TestCase

  include DefinesConstants

  def setup
    super
    reset_config
  end

  def set_public_env
    SkywriterClient.configure { |config| config.environment_name = 'production' }
  end

  def set_development_env
    SkywriterClient.configure { |config| config.environment_name = 'development' }
  end

  def set_test_env
    SkywriterClient.configure { |config| config.environment_name = 'test' }
  end

  should "yield and save a configuration when configuring" do
    yielded_configuration = nil
    SkywriterClient.configure do |config|
      yielded_configuration = config
    end

    assert_kind_of SkywriterClient::Configuration, yielded_configuration
    assert_equal yielded_configuration, SkywriterClient.configuration
  end

  should "not remove existing config options when configuring twice" do
    first_config = nil
    SkywriterClient.configure do |config|
      first_config = config
    end
    SkywriterClient.configure do |config|
      assert_equal first_config, config
    end
  end

  should "configure the client" do
    client = stub_client
    SkywriterClient::Client.stubs(:new => client)
    configuration = nil

    SkywriterClient.configure { |yielded_config| configuration = yielded_config }

    assert_received(SkywriterClient::Client, :new) { |expect| expect.with(configuration) }
    assert_equal client, SkywriterClient.client
  end

  should "return the default content and not contact the server when in a test environment" do
    set_test_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_equal "default content",
                 SkywriterClient.sky_write("test.key", "default content")
    assert_not_requested :get, /skywriterapp.*/
  end

  should "return the default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*skywriterapp.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /skywriterapp.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_equal "default content",
                 SkywriterClient.sky_write("test.key", "default content")
  end

  should "return the default content when request raises a rescuable error" do
    set_development_env
    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |exception|
      reset_webmock
      stub_request(:get, /skywriterapp.*/).to_raise(exception)
      assert_equal "default content",
                   SkywriterClient.sky_write("test.key", "default content")
      SkywriterClient.enable_remote_lookup
    end
  end

  should "timeout after two seconds" do
    response = mock('response')
    response.stubs('code' => 200, 'body' => 'test', '[]' => nil)
    SkywriterClient::Client.expects(:get).with(anything, has_entries(:timeout => 2)).returns(response)
    SkywriterClient.sky_write("test.key", "default content")
  end

  should "disable remote calls on exception for 5 minutes" do
    set_development_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_timeout
    SkywriterClient.sky_write("test.key", "default content")
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "not default content")
    assert_equal "default content",
                 SkywriterClient.sky_write("test.key", "default content")
    SkywriterClient.enable_remote_lookup
    assert_equal "not default content",
                 SkywriterClient.sky_write("test.key", "default content")

  end

  should "return nil when there is no default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*skywriterapp.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /skywriterapp.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_nil SkywriterClient.sky_write("test.key")
    assert_requested :post, /skywriterapp.*/
  end

  should "return the editable content when specifying a key that has content" do
    set_development_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id></blurb>\n")

    assert_match "the content", SkywriterClient.sky_write("test.key")
    assert_match "<a target='_blank' href='http://skywriterapp.com/projects/1/blurbs/9/edit'>Edit</a>",
                 SkywriterClient.sky_write("test.key", "default content")
  end

  should "return the editable content when specifying a key that has content even with a default" do
    set_development_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    assert_match "the content",
                 SkywriterClient.sky_write("test.key", "default content")
    assert_match "<a target='_blank' href='http://skywriterapp.com/projects/1/blurbs/9/edit'>Edit</a>",
                 SkywriterClient.sky_write("test.key", "default content")
  end

  should "not include edit link in content in public env" do
    set_public_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    assert_no_match /Edit/, SkywriterClient.sky_write("test.key")
  end

  should "escape HTML entities" do
    set_public_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>&lt;b&gt;the content&lt;/b&gt;</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    assert_equal "<b>the content</b>", SkywriterClient.sky_write("test.key").strip
  end

  should "respond to s" do
    assert SkywriterClient.respond_to?(:s)
  end

  should "perform caching when sky writing" do
    cache = mock('Cache')
    cache.stubs(:fetch).yields.returns("cached-content")

    ::Rails = Class.new
    ::Rails.stubs(:cache).returns(cache)

    SkywriterClient.configuration.cache_enabled    = true
    SkywriterClient.configuration.cache_expires_in = 60

    assert_equal "cached-content", SkywriterClient.sky_write("key")
    assert_received(cache, :fetch) do |expect|
      expect.with "skywriter.key", { :expires_in => 60 }
    end
  end
end
