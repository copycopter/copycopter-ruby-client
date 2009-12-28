require File.dirname(__FILE__) + '/helper'

class ClientTest < Test::Unit::TestCase

  def setup
    reset_config
  end

  def build_sender(opts = {})
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

end
