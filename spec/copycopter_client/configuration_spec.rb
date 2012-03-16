require 'spec_helper'

describe CopycopterClient::Configuration do
  RSpec::Matchers.define :have_config_option do |option|
    match do |config|
      config.should respond_to(option)

      if instance_variables.include?('@default')
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

  it { should have_config_option(:proxy_host).overridable.default(nil) }
  it { should have_config_option(:proxy_port).overridable.default(nil) }
  it { should have_config_option(:proxy_user).overridable.default(nil) }
  it { should have_config_option(:proxy_pass).overridable.default(nil) }
  it { should have_config_option(:environment_name).overridable.default(nil) }
  it { should have_config_option(:client_version).overridable.default(CopycopterClient::VERSION) }
  it { should have_config_option(:client_name).overridable.default('Copycopter Client') }
  it { should have_config_option(:client_url).overridable.default('http://copycopter.com') }
  it { should have_config_option(:secure).overridable.default(true) }
  it { should have_config_option(:host).overridable.default('copycopter.com') }
  it { should have_config_option(:http_open_timeout).overridable.default(2) }
  it { should have_config_option(:http_read_timeout).overridable.default(5) }
  it { should have_config_option(:port).overridable }
  it { should have_config_option(:development_environments).overridable }
  it { should have_config_option(:api_key).overridable }
  it { should have_config_option(:polling_delay).overridable.default(300) }
  it { should have_config_option(:framework).overridable }
  it { should have_config_option(:middleware).overridable }
  it { should have_config_option(:client).overridable }
  it { should have_config_option(:cache).overridable }

  it 'should provide default values for secure connections' do
    config = CopycopterClient::Configuration.new
    config.secure = true
    config.port.should == 443
    config.protocol.should == 'https'
  end

  it 'should provide default values for insecure connections' do
    config = CopycopterClient::Configuration.new
    config.secure = false
    config.port.should == 80
    config.protocol.should == 'http'
  end

  it 'should not cache inferred ports' do
    config = CopycopterClient::Configuration.new
    config.secure = false
    config.port
    config.secure = true
    config.port.should == 443
  end

  it 'should act like a hash' do
    config = CopycopterClient::Configuration.new
    hash = config.to_hash

    [:api_key, :environment_name, :host, :http_open_timeout,
      :http_read_timeout, :client_name, :client_url, :client_version, :port,
      :protocol, :proxy_host, :proxy_pass, :proxy_port, :proxy_user, :secure,
      :development_environments, :logger, :framework, :ca_file].each do |option|
      hash[option].should == config[option]
    end

    hash[:public].should == config.public?
  end

  it 'should be mergable' do
    config = CopycopterClient::Configuration.new
    hash = config.to_hash
    config.merge(:key => 'value').should == hash.merge(:key => 'value')
  end

  it 'should use development and staging as development environments by default' do
    config = CopycopterClient::Configuration.new
    config.development_environments.should =~ %w(development staging)
  end

  it 'should use test and cucumber as test environments by default' do
    config = CopycopterClient::Configuration.new
    config.test_environments.should =~ %w(test cucumber)
  end

  it 'should be test in a test environment' do
    config = CopycopterClient::Configuration.new
    config.test_environments = %w(test)
    config.environment_name = 'test'
    config.should be_test
  end

  it 'should be public in a public environment' do
    config = CopycopterClient::Configuration.new
    config.development_environments = %w(development)
    config.environment_name = 'production'
    config.should be_public
    config.should_not be_development
  end

  it 'should be development in a development environment' do
    config = CopycopterClient::Configuration.new
    config.development_environments = %w(staging)
    config.environment_name = 'staging'
    config.should be_development
    config.should_not be_public
  end

  it 'should be public without an environment name' do
    config = CopycopterClient::Configuration.new
    config.should be_public
  end

  it 'should yield and save a configuration when configuring' do
    yielded_configuration = nil

    CopycopterClient.configure(false) do |config|
      yielded_configuration = config
    end

    yielded_configuration.should be_kind_of(CopycopterClient::Configuration)
    CopycopterClient.configuration.should == yielded_configuration
  end

  it 'does not apply the configuration when asked not to' do
    logger = FakeLogger.new
    CopycopterClient.configure(false) { |config| config.logger = logger }
    CopycopterClient.configuration.should_not be_applied
    logger.entries[:info].should be_empty
  end

  it 'should not remove existing config options when configuring twice' do
    first_config = nil

    CopycopterClient.configure(false) do |config|
      first_config = config
    end

    CopycopterClient.configure(false) do |config|
      config.should == first_config
    end
  end

  it 'starts out unapplied' do
    CopycopterClient::Configuration.new.should_not be_applied
  end

  it 'logs to $stdout by default' do
    logger = FakeLogger.new
    Logger.stubs :new => logger
    config = CopycopterClient::Configuration.new
    Logger.should have_received(:new).with($stdout)
    config.logger.original_logger.should == logger
  end

  it 'generates environment info without a framework' do
    subject.environment_name = 'production'
    subject.environment_info.should == "[Ruby: #{RUBY_VERSION}] [Env: production]"
  end

  it 'generates environment info with a framework' do
    subject.environment_name = 'production'
    subject.framework = 'Sinatra: 1.0.0'
    subject.environment_info.
      should == "[Ruby: #{RUBY_VERSION}] [Sinatra: 1.0.0] [Env: production]"
  end

  it 'prefixes log entries' do
    logger = FakeLogger.new
    config = CopycopterClient::Configuration.new

    config.logger = logger

    prefixed_logger = config.logger
    prefixed_logger.should be_a(CopycopterClient::PrefixedLogger)
    prefixed_logger.original_logger.should == logger
  end
end

share_examples_for 'applied configuration' do
  subject { CopycopterClient::Configuration.new }
  let(:backend) { stub('i18n-backend') }
  let(:cache) { stub('cache') }
  let(:client) { stub('client') }
  let(:logger) { FakeLogger.new }
  let(:poller) { stub('poller') }
  let(:process_guard) { stub('process_guard', :start => nil) }

  before do
    CopycopterClient::I18nBackend.stubs :new => backend
    CopycopterClient::Client.stubs :new => client
    CopycopterClient::Cache.stubs :new => cache
    CopycopterClient::Poller.stubs :new => poller
    CopycopterClient::ProcessGuard.stubs :new => process_guard
    subject.logger = logger
    apply
  end

  it { should be_applied }

  it 'builds and assigns an I18n backend' do
    CopycopterClient::I18nBackend.should have_received(:new).with(cache)
    I18n.backend.should == backend
  end

  it 'builds and assigns a poller' do
    CopycopterClient::Poller.should have_received(:new).with(cache, subject.to_hash)
  end

  it 'builds a process guard' do
    CopycopterClient::ProcessGuard.should have_received(:new).
      with(cache, poller, subject.to_hash)
  end

  it 'logs that it is ready' do
    logger.should have_entry(:info, "Client #{CopycopterClient::VERSION} ready")
  end

  it 'logs environment info' do
    logger.should have_entry(:info, "Environment Info: #{subject.environment_info}")
  end
end

describe CopycopterClient::Configuration, 'applied when testing' do
  it_should_behave_like 'applied configuration' do
    it 'does not start the process guard' do
      process_guard.should have_received(:start).never
    end
  end

  def apply
    subject.environment_name = 'test'
    subject.apply
  end
end

describe CopycopterClient::Configuration, 'applied when not testing' do
  it_should_behave_like 'applied configuration' do
    it 'starts the process guard' do
      process_guard.should have_received(:start)
    end
  end

  def apply
    subject.environment_name = 'development'
    subject.apply
  end
end

describe CopycopterClient::Configuration, 'applied when developing with middleware' do
  it_should_behave_like 'applied configuration' do
    it 'adds the sync middleware' do
      middleware.should include(CopycopterClient::RequestSync)
    end
  end

  let(:middleware) { MiddlewareStack.new }

  def apply
    subject.middleware = middleware
    subject.environment_name = 'development'
    subject.apply
  end
end

describe CopycopterClient::Configuration, 'applied when developing without middleware' do
  it_should_behave_like 'applied configuration'

  def apply
    subject.middleware = nil
    subject.environment_name = 'development'
    subject.apply
  end
end

describe CopycopterClient::Configuration, 'applied with middleware when not developing' do
  it_should_behave_like 'applied configuration'

  let(:middleware) { MiddlewareStack.new }

  def apply
    subject.middleware = middleware
    subject.environment_name = 'test'
    subject.apply
  end

  it 'does not add the sync middleware' do
    middleware.should_not include(CopycopterClient::RequestSync)
  end
end

