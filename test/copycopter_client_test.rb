require File.dirname(__FILE__) + '/helper'

class CopycopterclientTest < Test::Unit::TestCase

  include DefinesConstants

  def setup
    super
    reset_config
  end

  def set_public_env
    CopycopterClient.configure { |config| config.environment_name = 'production' }
  end

  def set_development_env
    CopycopterClient.configure { |config| config.environment_name = 'development' }
  end

  def set_test_env
    CopycopterClient.configure { |config| config.environment_name = 'test' }
  end

  should "yield and save a configuration when configuring" do
    yielded_configuration = nil
    CopycopterClient.configure do |config|
      yielded_configuration = config
    end

    assert_kind_of CopycopterClient::Configuration, yielded_configuration
    assert_equal yielded_configuration, CopycopterClient.configuration
  end

  should "not remove existing config options when configuring twice" do
    first_config = nil
    CopycopterClient.configure do |config|
      first_config = config
    end
    CopycopterClient.configure do |config|
      assert_equal first_config, config
    end
  end

  should "configure the client" do
    client = stub_client
    CopycopterClient::Client.stubs(:new => client)
    configuration = nil

    CopycopterClient.configure { |yielded_config| configuration = yielded_config }

    assert_received(CopycopterClient::Client, :new) { |expect| expect.with(configuration) }
    assert_equal client, CopycopterClient.client
  end

  should "return the default content and not contact the server when in a test environment" do
    set_test_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_equal "default content",
                 CopycopterClient.copy_for("test.key", "default content")
    assert_not_requested :get, /copycopter.*/
  end

  should "return the default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*copycopter.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_equal "default content",
                 CopycopterClient.copy_for("test.key", "default content")
  end

  should "return the default content when request raises a rescuable error" do
    set_development_env
    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |exception|
      reset_webmock
      stub_request(:get, /copycopter.*/).to_raise(exception)
      assert_equal "default content",
                   CopycopterClient.copy_for("test.key", "default content")
      CopycopterClient.enable_remote_lookup
    end
  end

  should "timeout after two seconds" do
    response = mock('response')
    response.stubs('code' => 200, 'body' => 'test', '[]' => nil)
    CopycopterClient::Client.expects(:get).with(anything, has_entries(:timeout => 2)).returns(response)
    CopycopterClient.copy_for("test.key", "default content")
  end

  should "disable remote calls on exception for 5 minutes" do
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_timeout
    CopycopterClient.copy_for("test.key", "default content")
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "not default content")
    assert_equal "default content",
                 CopycopterClient.copy_for("test.key", "default content")
    CopycopterClient.enable_remote_lookup
    assert_equal "not default content",
                 CopycopterClient.copy_for("test.key", "default content")

  end

  should "return nil when there is no default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*copycopter.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_nil CopycopterClient.copy_for("test.key")
    assert_requested :post, /copycopter.*/
  end

  should "return the editable content when specifying a key that has content" do
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id></blurb>\n")

    assert_match "the content", CopycopterClient.copy_for("test.key")
    assert_match "<a target='_blank' href='http://copycopter.com/projects/1/blurbs/9/edit'>Edit</a>",
                 CopycopterClient.copy_for("test.key", "default content")
  end

  should "return the editable content when specifying a key that has content even with a default" do
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    assert_match "the content",
                 CopycopterClient.copy_for("test.key", "default content")
    assert_match "<a target='_blank' href='http://copycopter.com/projects/1/blurbs/9/edit'>Edit</a>",
                 CopycopterClient.copy_for("test.key", "default content")
  end

  should "not include edit link in content in public env" do
    set_public_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    assert_no_match /Edit/, CopycopterClient.copy_for("test.key")
  end

  should "escape HTML entities" do
    set_public_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>&lt;b&gt;the content&lt;/b&gt;</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    assert_equal "<b>the content</b>", CopycopterClient.copy_for("test.key").strip
  end

  should "respond to s" do
    assert CopycopterClient.respond_to?(:s)
  end

  should "perform caching when fetching copy" do
    cache = mock('Cache')
    cache.stubs(:fetch).yields.returns("cached-content")

    ::Rails = Class.new
    ::Rails.stubs(:cache).returns(cache)

    CopycopterClient.configuration.cache_enabled    = true
    CopycopterClient.configuration.cache_expires_in = 60

    assert_equal "cached-content", CopycopterClient.copy_for("key")
    assert_received(cache, :fetch) do |expect|
      expect.with "copycopter.key", { :expires_in => 60 }
    end
  end
end
