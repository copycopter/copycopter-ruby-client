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

  should "return not found text for a key that doesn't exist when no default is specified" do
    set_development_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_equal "Blurb not found: test.key",
                 SkywriterClient.sky_write("test.key")
  end

  should "return the default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*skywriterapp.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /skywriterapp.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    assert_equal "default content",
                 SkywriterClient.sky_write("test.key", "default content")
  end

  should "return the editable content when specifying a key that has content" do
    set_development_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <created-at type=\"datetime\">2009-12-29T18:47:23Z</created-at>\n  <environment-id type=\"integer\">28</environment-id>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n  <key>test.key</key>\n  <updated-at type=\"datetime\">2009-12-29T18:47:23Z</updated-at>\n</blurb>\n")

    assert_match "the content", SkywriterClient.sky_write("test.key")
    assert_match "<a target='_blank' href='http://skywriterapp.com/projects/1/blurbs/9/edit'>Edit</a>",
                 SkywriterClient.sky_write("test.key", "default content")
  end

  should "return the editable content when specifying a key that has content even with a default" do
    set_development_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <created-at type=\"datetime\">2009-12-29T18:47:23Z</created-at>\n  <environment-id type=\"integer\">28</environment-id>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n  <key>test.key</key>\n  <updated-at type=\"datetime\">2009-12-29T18:47:23Z</updated-at>\n</blurb>\n")

    assert_match "the content",
                 SkywriterClient.sky_write("test.key", "default content")
    assert_match "<a target='_blank' href='http://skywriterapp.com/projects/1/blurbs/9/edit'>Edit</a>",
                 SkywriterClient.sky_write("test.key", "default content")
  end

  should "not include edit link in content in public env" do
    set_public_env
    reset_webmock
    stub_request(:get, /skywriterapp.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <created-at type=\"datetime\">2009-12-29T18:47:23Z</created-at>\n  <environment-id type=\"integer\">28</environment-id>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n  <key>test.key</key>\n  <updated-at type=\"datetime\">2009-12-29T18:47:23Z</updated-at>\n</blurb>\n")

    assert_no_match /Edit/, SkywriterClient.sky_write("test.key")
  end

  should "respond to s" do
    assert SkywriterClient.respond_to?(:s)
  end

end
