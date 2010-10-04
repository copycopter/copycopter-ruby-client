require 'spec_helper'

describe CopycopterClient do
  include DefinesConstants

  before do
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

  it "should yield and save a configuration when configuring" do
    yielded_configuration = nil
    CopycopterClient.configure do |config|
      yielded_configuration = config
    end

    yielded_configuration.should be_kind_of(CopycopterClient::Configuration)
    CopycopterClient.configuration.should == yielded_configuration
  end

  it "should not remove existing config options when configuring twice" do
    first_config = nil
    CopycopterClient.configure do |config|
      first_config = config
    end
    CopycopterClient.configure do |config|
      config.should == first_config
    end
  end

  it "should configure the client" do
    client = stub_client
    CopycopterClient::Client.stubs(:new => client)
    configuration = nil

    CopycopterClient.configure { |yielded_config| configuration = yielded_config }

    CopycopterClient::Client.should have_received(:new).with(configuration)
    CopycopterClient.client.should == client
  end

  it "should return the default content and not contact the server when in a test environment" do
    set_test_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    CopycopterClient.copy_for("test.key", "default content").should == "default content"
    WebMock.should_not have_requested(:get, /copycopter.*/)
  end

  it "should return the default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*copycopter.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    CopycopterClient.copy_for("test.key", "default content").should == "default content"
  end

  it "should return the default content when request raises a rescuable error" do
    set_development_env
    [Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError].each do |exception|
      reset_webmock
      stub_request(:get, /copycopter.*/).to_raise(exception)
      CopycopterClient.copy_for("test.key", "default content").should == "default content"
      CopycopterClient.enable_remote_lookup
    end
  end

  it "should timeout after two seconds" do
    response = mock('response')
    response.stubs('code' => 200, 'body' => 'test', '[]' => nil)
    CopycopterClient::Client.expects(:get).with(anything, has_entries(:timeout => 2)).returns(response)
    CopycopterClient.copy_for("test.key", "default content")
  end

  it "should disable remote calls on exception for 5 minutes" do
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_timeout
    CopycopterClient.copy_for("test.key", "default content")
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "not default content")
    CopycopterClient.copy_for("test.key", "default content").should == "default content"
    CopycopterClient.enable_remote_lookup
    CopycopterClient.copy_for("test.key", "default content").should == "not default content"
  end

  it "should return nil when there is no default content when specifying a key that doesn't exist" do
    set_development_env
    reset_webmock
    stub_request(:post, /.*copycopter.*/).to_return(:status => 200, :body => "Posted to test.key")
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    CopycopterClient.copy_for("test.key").should be_nil
    WebMock.should have_requested(:post, /copycopter.*/)
  end

  it "should return the editable content when specifying a key that has content" do
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id></blurb>\n")

    CopycopterClient.copy_for("test.key").should include("the content")
    CopycopterClient.copy_for("test.key", "default content").
      should include("<a target='_blank' href='http://copycopter.com/projects/1/blurbs/9/edit'>Edit</a>")
  end

  it "should return the editable content when specifying a key that has content even with a default" do
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    CopycopterClient.copy_for("test.key", "default content").
      should include("the content")
    CopycopterClient.copy_for("test.key", "default content").
      should include("<a target='_blank' href='http://copycopter.com/projects/1/blurbs/9/edit'>Edit</a>")
  end

  it "should not include edit link in content in public env" do
    set_public_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    CopycopterClient.copy_for("test.key").should_not =~ /Edit/
  end

  it "should escape HTML entities" do
    set_public_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>&lt;b&gt;the content&lt;/b&gt;</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    CopycopterClient.copy_for("test.key").strip.should == "<b>the content</b>"
  end

  it "should respond to s" do
    CopycopterClient.should respond_to(:s)
  end

  it "should perform caching when fetching copy" do
    cache = mock('Cache')
    cache.stubs(:fetch, anything).returns("cached-content")

    Rails.cache = cache

    CopycopterClient.configuration.cache_enabled    = true
    CopycopterClient.configuration.cache_expires_in = 60

    CopycopterClient.copy_for("key").should == "cached-content"
    cache.should have_received(:fetch).with("copycopter.key", :expires_in => 60)
  end
end
