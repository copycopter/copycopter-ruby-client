require File.dirname(__FILE__) + '/helper'

class HelperTest < Test::Unit::TestCase

  include SkywriterClient::Helper

  should "define a sky_write method" do
    assert respond_to?(:sky_write)
  end

  should "define a s method" do
    assert respond_to?(:s)
  end

end
