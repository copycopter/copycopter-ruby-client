require 'spec_helper'

describe CopyTunerClient::Configuration do
  RSpec::Matchers.define :have_config_option do |option|
    match do |config|
      expect(config).to respond_to(option)

      if instance_variables.include?(:'@default')
        expect(config.send(option)).to eq(@default)
      end

      if @overridable
        value = 'a value'
        config.send(:"#{option}=", value)
        expect(config.send(option)).to eq(value)
      end
    end

    chain :default do |default|
      @default = default
    end

    chain :overridable do
      @overridable = true
    end
  end

  it { is_expected.to have_config_option(:proxy_host).overridable.default(nil) }
  it { is_expected.to have_config_option(:proxy_port).overridable.default(nil) }
  it { is_expected.to have_config_option(:proxy_user).overridable.default(nil) }
  it { is_expected.to have_config_option(:proxy_pass).overridable.default(nil) }
  it { is_expected.to have_config_option(:environment_name).overridable.default(nil) }
  it { is_expected.to have_config_option(:client_version).overridable.default(CopyTunerClient::VERSION) }
  it { is_expected.to have_config_option(:client_name).overridable.default('CopyTuner Client') }
  it { is_expected.to have_config_option(:client_url).overridable.default('https://rubygems.org/gems/copy_tuner_client') }
  it { is_expected.to have_config_option(:secure).overridable.default(true) }
  it { is_expected.to have_config_option(:host).overridable.default('copy-tuner.com') }
  it { is_expected.to have_config_option(:http_open_timeout).overridable.default(5) }
  it { is_expected.to have_config_option(:http_read_timeout).overridable.default(5) }
  it { is_expected.to have_config_option(:port).overridable }
  it { is_expected.to have_config_option(:development_environments).overridable }
  it { is_expected.to have_config_option(:api_key).overridable }
  it { is_expected.to have_config_option(:polling_delay).overridable.default(300) }
  it { is_expected.to have_config_option(:framework).overridable }
  it { is_expected.to have_config_option(:middleware).overridable }
  it { is_expected.to have_config_option(:client).overridable }
  it { is_expected.to have_config_option(:cache).overridable }

  it 'should provide default values for secure connections' do
    config = CopyTunerClient::Configuration.new
    config.secure = true
    expect(config.port).to eq(443)
    expect(config.protocol).to eq('https')
  end

  it 'should provide default values for insecure connections' do
    config = CopyTunerClient::Configuration.new
    config.secure = false
    expect(config.port).to eq(80)
    expect(config.protocol).to eq('http')
  end

  it 'should not cache inferred ports' do
    config = CopyTunerClient::Configuration.new
    config.secure = false
    config.port
    config.secure = true
    expect(config.port).to eq(443)
  end

  it 'should act like a hash' do
    config = CopyTunerClient::Configuration.new
    hash = config.to_hash

    [:api_key, :environment_name, :host, :http_open_timeout,
      :http_read_timeout, :client_name, :client_url, :client_version, :port,
      :protocol, :proxy_host, :proxy_pass, :proxy_port, :proxy_user, :secure,
      :development_environments, :logger, :framework, :ca_file].each do |option|
      expect(hash[option]).to eq(config[option])
    end

    expect(hash[:public]).to eq(config.public?)
  end

  it 'should be mergable' do
    config = CopyTunerClient::Configuration.new
    hash = config.to_hash
    expect(config.merge(:key => 'value')).to eq(hash.merge(:key => 'value'))
  end

  it 'should use development and staging as development environments by default' do
    config = CopyTunerClient::Configuration.new
    expect(config.development_environments).to match_array(%w(development staging))
  end

  it 'should use test and cucumber as test environments by default' do
    config = CopyTunerClient::Configuration.new
    expect(config.test_environments).to match_array(%w(test cucumber))
  end

  it 'should be test in a test environment' do
    config = CopyTunerClient::Configuration.new
    config.test_environments = %w(test)
    config.environment_name = 'test'
    expect(config).to be_test
  end

  it 'should be public in a public environment' do
    config = CopyTunerClient::Configuration.new
    config.development_environments = %w(development)
    config.environment_name = 'production'
    expect(config).to be_public
    expect(config).not_to be_development
  end

  it 'should be development in a development environment' do
    config = CopyTunerClient::Configuration.new
    config.development_environments = %w(staging)
    config.environment_name = 'staging'
    expect(config).to be_development
    expect(config).not_to be_public
  end

  it 'should be public without an environment name' do
    config = CopyTunerClient::Configuration.new
    expect(config).to be_public
  end

  it 'should yield and save a configuration when configuring' do
    yielded_configuration = nil

    CopyTunerClient.configure(false) do |config|
      yielded_configuration = config
    end

    expect(yielded_configuration).to be_kind_of(CopyTunerClient::Configuration)
    expect(CopyTunerClient.configuration).to eq(yielded_configuration)
  end

  it 'does not apply the configuration when asked not to' do
    logger = FakeLogger.new
    CopyTunerClient.configure(false) { |config| config.logger = logger }
    expect(CopyTunerClient.configuration).not_to be_applied
    expect(logger.entries[:info]).to be_empty
  end

  it 'should not remove existing config options when configuring twice' do
    first_config = nil

    CopyTunerClient.configure(false) do |config|
      first_config = config
    end

    CopyTunerClient.configure(false) do |config|
      expect(config).to eq(first_config)
    end
  end

  it 'starts out unapplied' do
    expect(CopyTunerClient::Configuration.new).not_to be_applied
  end

  it 'logs to $stdout by default' do
    logger = FakeLogger.new
    Logger.stubs :new => logger
    config = CopyTunerClient::Configuration.new
    expect(Logger).to have_received(:new).with($stdout)
    expect(config.logger.original_logger).to eq(logger)
  end

  it 'generates environment info without a framework' do
    subject.environment_name = 'production'
    expect(subject.environment_info).to eq("[Ruby: #{RUBY_VERSION}] [Env: production]")
  end

  it 'generates environment info with a framework' do
    subject.environment_name = 'production'
    subject.framework = 'Sinatra: 1.0.0'
    expect(subject.environment_info).
      to eq("[Ruby: #{RUBY_VERSION}] [Sinatra: 1.0.0] [Env: production]")
  end

  it 'prefixes log entries' do
    logger = FakeLogger.new
    config = CopyTunerClient::Configuration.new

    config.logger = logger

    prefixed_logger = config.logger
    expect(prefixed_logger).to be_a(CopyTunerClient::PrefixedLogger)
    expect(prefixed_logger.original_logger).to eq(logger)
  end
end

shared_context 'stubbed configuration' do
  subject { CopyTunerClient::Configuration.new }
  let(:backend) { stub('i18n-backend') }
  let(:cache) { stub('cache', :download => "download") }
  let(:client) { stub('client') }
  let(:logger) { FakeLogger.new }
  let(:poller) { stub('poller') }
  let(:process_guard) { stub('process_guard', :start => nil) }

  before do
    CopyTunerClient::I18nBackend.stubs :new => backend
    CopyTunerClient::Client.stubs :new => client
    CopyTunerClient::Cache.stubs :new => cache
    CopyTunerClient::Poller.stubs :new => poller
    CopyTunerClient::ProcessGuard.stubs :new => process_guard
    subject.logger = logger
    apply
  end
end

shared_examples_for 'applied configuration' do
  include_context 'stubbed configuration'

  it { is_expected.to be_applied }

  it 'builds and assigns an I18n backend' do
    expect(CopyTunerClient::I18nBackend).to have_received(:new).with(cache)
    expect(I18n.backend).to eq(backend)
  end

  it 'builds and assigns a poller' do
    expect(CopyTunerClient::Poller).to have_received(:new).with(cache, subject.to_hash)
  end

  it 'builds a process guard' do
    expect(CopyTunerClient::ProcessGuard).to have_received(:new).
      with(cache, poller, subject.to_hash)
  end

  it 'logs that it is ready' do
    expect(logger).to have_entry(:info, "Client #{CopyTunerClient::VERSION} ready")
  end

  it 'logs environment info' do
    expect(logger).to have_entry(:info, "Environment Info: #{subject.environment_info}")
  end
end

describe CopyTunerClient::Configuration, 'applied when testing' do
  it_should_behave_like 'applied configuration' do
    it 'does not start the process guard' do
      expect(process_guard).to have_received(:start).never
    end
  end

  def apply
    subject.environment_name = 'test'
    subject.apply
  end
end

describe CopyTunerClient::Configuration, 'applied when not testing' do
  it_should_behave_like 'applied configuration' do
    it 'starts the process guard' do
      expect(process_guard).to have_received(:start)
    end
  end

  def apply
    subject.environment_name = 'development'
    subject.apply
  end
end

describe CopyTunerClient::Configuration, 'applied when developing with middleware' do
  it_should_behave_like 'applied configuration' do
    it 'adds the sync middleware' do
      expect(middleware).to include(CopyTunerClient::RequestSync)
    end
  end

  let(:middleware) { MiddlewareStack.new }

  def apply
    subject.middleware = middleware
    subject.environment_name = 'development'
    subject.apply
  end
end

describe CopyTunerClient::Configuration, 'applied when developing without middleware' do
  it_should_behave_like 'applied configuration'

  def apply
    subject.middleware = nil
    subject.environment_name = 'development'
    subject.apply
  end
end

describe CopyTunerClient::Configuration, 'applied with middleware when not developing' do
  it_should_behave_like 'applied configuration'

  let(:middleware) { MiddlewareStack.new }

  def apply
    subject.middleware = middleware
    subject.environment_name = 'test'
    subject.apply
  end

  it 'does not add the sync middleware' do
    expect(middleware).not_to include(CopyTunerClient::RequestSync)
  end
end

describe CopyTunerClient::Configuration, 'applied without locale filter' do
  include_context 'stubbed configuration'

  def apply
    subject.apply
  end

  it 'should have locales [:en]' do
    expect(subject.locales).to eq [:en]
  end
end

describe CopyTunerClient::Configuration, 'applied with locale filter' do
  include_context 'stubbed configuration'

  def apply
    subject.locales = %i(en ja)
    subject.apply
  end

  it 'should have locales %i(en ja)' do
    expect(subject.locales).to eq %i(en ja)
  end
end

describe CopyTunerClient::Configuration, 'applied with Rails i18n config' do
  def self.with_config(i18n_options)
    around do |ex|
      rails_defined = Object.const_defined?(:Rails)
      Object.const_set :Rails, Module.new unless rails_defined
      i18n = stub(i18n_options)
      Rails.stubs application: stub(config: stub(i18n: i18n))
      ex.run
      Object.send(:remove_const, :Rails) unless rails_defined
    end
  end

  def apply
    subject.apply
  end

  context 'with available_locales' do
    with_config(available_locales: %i(en ja))
    include_context 'stubbed configuration'

    it 'should have locales %i(en ja)' do
      expect(subject.locales).to eq %i(en ja)
    end
  end

  context 'with default_locale' do
    with_config(available_locales: %i(ja))
    include_context 'stubbed configuration'

    it 'should have locales %i(ja)' do
      expect(subject.locales).to eq %i(ja)
    end
  end
end
