require File.dirname(__FILE__) + '/helper'

class ConfigurationTest < Test::Unit::TestCase

  should "provide default values" do
    assert_config_default :proxy_host,          nil
    assert_config_default :proxy_port,          nil
    assert_config_default :proxy_user,          nil
    assert_config_default :proxy_pass,          nil
    assert_config_default :environment_name,    nil
    assert_config_default :client_version,      SkywriterClient::VERSION
    assert_config_default :client_name,         'SkyWriter Client'
    assert_config_default :client_url,          'http://getskywriter.com'
    assert_config_default :secure,              false
    assert_config_default :host,                'getskywriter.com'
    assert_config_default :http_open_timeout,   2
    assert_config_default :http_read_timeout,   5
  end

  should "provide default values for secure connections" do
    config = SkywriterClient::Configuration.new
    config.secure = true
    assert_equal 443, config.port
    assert_equal 'https', config.protocol
  end

  should "provide default values for insecure connections" do
    config = SkywriterClient::Configuration.new
    config.secure = false
    assert_equal 80, config.port
    assert_equal 'http', config.protocol
  end

  should "not cache inferred ports" do
    config = SkywriterClient::Configuration.new
    config.secure = false
    config.port
    config.secure = true
    assert_equal 443, config.port
  end

  should "allow values to be overwritten" do
    assert_config_overridable :proxy_host
    assert_config_overridable :proxy_port
    assert_config_overridable :proxy_user
    assert_config_overridable :proxy_pass
    assert_config_overridable :secure
    assert_config_overridable :host
    assert_config_overridable :port
    assert_config_overridable :http_open_timeout
    assert_config_overridable :http_read_timeout
    assert_config_overridable :client_version
    assert_config_overridable :client_name
    assert_config_overridable :client_url
    assert_config_overridable :environment_name
    assert_config_overridable :development_environments
  end

  should "have an api key" do
    assert_config_overridable :api_key
  end

  should "act like a hash" do
    config = SkywriterClient::Configuration.new
    hash = config.to_hash
    [:api_key, :environment_name, :host, :http_open_timeout,
     :http_read_timeout, :client_name, :client_url, :client_version, 
     :port, :protocol, :proxy_host, :proxy_pass, :proxy_port,
     :proxy_user, :secure, :development_environments].each do |option|
      assert_equal config[option], hash[option], "Wrong value for #{option}"
    end
  end

  should "be mergable" do
    config = SkywriterClient::Configuration.new
    hash = config.to_hash
    assert_equal hash.merge(:key => 'value'), config.merge(:key => 'value')
  end

  should "use development and test as development environments by default" do
    config = SkywriterClient::Configuration.new
    assert_same_elements %w(development test cucumber), config.development_environments
  end

  should "be public in a public environment" do
    config = SkywriterClient::Configuration.new
    config.development_environments = %w(development)
    config.environment_name = 'production'
    assert config.public?
  end

  should "not be public in a development environment" do
    config = SkywriterClient::Configuration.new
    config.development_environments = %w(staging)
    config.environment_name = 'staging'
    assert !config.public?
  end

  should "be public without an environment name" do
    config = SkywriterClient::Configuration.new
    assert config.public?
  end

  def assert_config_default(option, default_value, config = nil)
    config ||= SkywriterClient::Configuration.new
    assert_equal default_value, config.send(option)
  end

  def assert_config_overridable(option, value = 'a value')
    config = SkywriterClient::Configuration.new
    config.send(:"#{option}=", value)
    assert_equal value, config.send(option)
  end

  def assert_appends_value(option, &block)
    config = SkywriterClient::Configuration.new
    original_values = config.send(option).dup
    block ||= lambda do |config|
      new_value = 'hello'
      config.send(option) << new_value
      new_value
    end
    new_value = block.call(config)
    assert_same_elements original_values + [new_value], config.send(option)
  end

  def assert_replaces(option, setter)
    config = SkywriterClient::Configuration.new
    new_value = 'hello'
    config.send(setter, [new_value])
    assert_equal [new_value], config.send(option)
    config.send(setter, new_value)
    assert_equal [new_value], config.send(option)
  end

end
