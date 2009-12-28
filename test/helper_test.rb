require File.dirname(__FILE__) + '/helper'

class HelperTest < Test::Unit::TestCase

  include SkywriterClient::Helper

  def setup
    reset_config
  end

  should "return nil for a key that doesn't exist when no default is specified" do
    assert_nil s("test.key")
  end

  should "return the default content when specifying a key that doesn't exist" do
    assert_equal "default content", s("test.key", "default content")
  end

  should "return the content when specifying a key that has content" do
    assert_equal "the content", s("test.key")
  end

  should "return the content when specifying a key that has content even with a default" do
    assert_equal "the content", s("test.key", "default content")
  end

end
