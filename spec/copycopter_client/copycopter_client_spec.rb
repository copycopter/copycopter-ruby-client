require 'spec_helper'

describe CopycopterClient do
  include DefinesConstants

  def set_public_env
    CopycopterClient.configure { |config| config.environment_name = 'production' }
  end

  def set_development_env
    CopycopterClient.configure { |config| config.environment_name = 'development' }
  end

  def set_test_env
    CopycopterClient.configure { |config| config.environment_name = 'test' }
  end

  it "should return the default content and not contact the server when in a test environment" do
    pending
    set_test_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 404, :body => "Blurb not found: test.key")

    CopycopterClient.copy_for("test.key", "default content").should == "default content"
    WebMock.should_not have_requested(:get, /copycopter.*/)
  end

  it "should disable remote calls on exception for 5 minutes" do
    pending
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

  it "should return the editable content when specifying a key that has content" do
    pending
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id></blurb>\n")

    CopycopterClient.copy_for("test.key").should include("the content")
    CopycopterClient.copy_for("test.key", "default content").
      should include("<a target='_blank' href='http://copycopter.com/projects/1/blurbs/9/edit'>Edit</a>")
  end

  it "should return the editable content when specifying a key that has content even with a default" do
    pending
    set_development_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    CopycopterClient.copy_for("test.key", "default content").
      should include("the content")
    CopycopterClient.copy_for("test.key", "default content").
      should include("<a target='_blank' href='http://copycopter.com/projects/1/blurbs/9/edit'>Edit</a>")
  end

  it "should not include edit link in content in public env" do
    pending
    set_public_env
    reset_webmock
    stub_request(:get, /copycopter.*/).to_return(:status => 200, :body => "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<blurb>\n  <content>the content</content>\n  <project-id type=\"integer\">1</project-id>\n  <id type=\"integer\">9</id>\n</blurb>\n")

    CopycopterClient.copy_for("test.key").should_not =~ /Edit/
  end
end
