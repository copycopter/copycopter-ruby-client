require 'spec_helper'

describe CopycopterClient::Configuration do
  Spec::Matchers.define :have_config_option do |option|
    match do |config|
      config.should respond_to(option)

      if instance_variables.include?('default')
        config.send(option).should == @default
      end

      if @overridable
        value = 'a value'
        config.send(:"#{option}=", value)
        config.send(option).should == value
      end
    end

    chain :default do |default|
      @default = default
    end

    chain :overridable do
      @overridable = true
    end
  end

  it { should have_config_option(:proxy_host).              overridable.default(nil) }
  it { should have_config_option(:proxy_port).              overridable.default(nil) }
  it { should have_config_option(:proxy_user).              overridable.default(nil) }
  it { should have_config_option(:proxy_pass).              overridable.default(nil) }
  it { should have_config_option(:environment_name).        overridable.default(nil) }
  it { should have_config_option(:client_version).          overridable.default(CopycopterClient::VERSION) }
  it { should have_config_option(:client_name).             overridable.default('Copycopter Client') }
  it { should have_config_option(:client_url).              overridable.default('http://copycopter.com') }
  it { should have_config_option(:secure).                  overridable.default(false) }
  it { should have_config_option(:host).                    overridable.default('copycopter.com') }
  it { should have_config_option(:http_open_timeout).       overridable.default(2) }
  it { should have_config_option(:http_read_timeout).       overridable.default(5) }
  it { should have_config_option(:cache_enabled).           overridable.default(false) }
  it { should have_config_option(:cache_expires_in).        overridable.default(nil) }
  it { should have_config_option(:port).                    overridable }
  it { should have_config_option(:development_environments).overridable }
  it { should have_config_option(:api_key).                 overridable }

  it "should provide default values for secure connections" do
    config = CopycopterClient::Configuration.new
    config.secure = true
    config.port.should == 443
    config.protocol.should == 'https'
  end

  it "should provide default values for insecure connections" do
    config = CopycopterClient::Configuration.new
    config.secure = false
    config.port.should == 80
    config.protocol.should == 'http'
  end

  it "should not cache inferred ports" do
    config = CopycopterClient::Configuration.new
    config.secure = false
    config.port
    config.secure = true
    config.port.should == 443
  end

  it "should act like a hash" do
    config = CopycopterClient::Configuration.new
    hash = config.to_hash
    [:api_key, :environment_name, :host, :http_open_timeout,
     :http_read_timeout, :client_name, :client_url, :client_version,
     :port, :protocol, :proxy_host, :proxy_pass, :proxy_port,
     :proxy_user, :secure, :development_environments].each do |option|
      hash[option].should == config[option]
    end
  end

  it "should be mergable" do
    config = CopycopterClient::Configuration.new
    hash = config.to_hash
    config.merge(:key => 'value').should == hash.merge(:key => 'value')
  end

  it "should use development and staging as development environments by default" do
    config = CopycopterClient::Configuration.new
    config.development_environments.should =~ %w(development staging)
  end

  it "should use test and cucumber as test environments by default" do
    config = CopycopterClient::Configuration.new
    config.test_environments.should =~ %w(test cucumber)
  end

  it "should be test in a test environment" do
    config = CopycopterClient::Configuration.new
    config.test_environments = %w(test)
    config.environment_name = 'test'
    config.should be_test
  end

  it "should be public in a public environment" do
    config = CopycopterClient::Configuration.new
    config.development_environments = %w(development)
    config.environment_name = 'production'
    config.should be_public
  end

  it "should not be public in a development environment" do
    config = CopycopterClient::Configuration.new
    config.development_environments = %w(staging)
    config.environment_name = 'staging'
    config.should_not be_public
  end

  it "should be public without an environment name" do
    config = CopycopterClient::Configuration.new
    config.should be_public
  end
end
