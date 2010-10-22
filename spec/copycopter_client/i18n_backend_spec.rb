require 'spec_helper'

describe CopycopterClient::I18nBackend do
  let(:sync) { {} }

  def build_backend(config = {})
    default_config = CopycopterClient::Configuration.new.to_hash
    backend = CopycopterClient::I18nBackend.new(sync, default_config.update(config))
    I18n.backend = backend
    backend
  end

  before { @default_backend = I18n.backend }
  after { I18n.backend = @default_backend }

  subject { build_backend }

  it "waits until the first download when reloaded" do
    sync.stubs(:wait_for_download)

    subject.reload!

    sync.should have_received(:wait_for_download)
  end

  it "includes the base i18n backend" do
    should be_kind_of(I18n::Backend::Base)
  end

  it "looks up a key in sync" do
    value = 'hello'
    sync['en.prefix.test.key'] = value

    backend = build_backend

    backend.translate('en', 'test.key', :scope => 'prefix').should == value
  end

  it "finds available locales" do
    sync['en.key'] = ''
    sync['fr.key'] = ''

    subject.available_locales.should =~ %w(en fr)
  end

  it "queues missing keys" do
    default = 'default value'

    subject.translate('en', 'test.key', :default => default).should == default

    sync['en.test.key'].should == default
  end

  it "marks strings as html safe" do
    sync['en.test.key'] = FakeHtmlSafeString.new("Hello")
    backend = build_backend
    backend.translate('en', 'test.key').should be_html_safe
  end

  it "looks up an array of defaults" do
    sync['en.key.one'] = "Expected"
    backend = build_backend
    backend.translate('en', 'key.three', :default => [:"key.two", :"key.one"]).
      should == 'Expected'
  end

  describe "with a fallback" do
    let(:fallback) { I18n::Backend::Simple.new }
    subject { build_backend(:fallback_backend => fallback) }

    it "uses the fallback as a default" do
      fallback.store_translations('en', 'test' => { 'key' => 'Expected' })
      subject.translate('en', 'test.key', :default => 'Unexpected').
        should include('Expected')
      sync['en.test.key'].should == 'Expected'
    end

    it "uses the default if the fallback doesn't have the key" do
      subject.translate('en', 'test.key', :default => 'Expected').
        should include('Expected')
    end

    it "uses the syncd key when present" do
      fallback.store_translations('en', 'test' => { 'key' => 'Unexpected' })
      sync['en.test.key'] = 'Expected'
      subject.translate('en', 'test.key', :default => 'default').
        should include('Expected')
    end

    it "returns a hash directly without storing" do
      nested = { :nested => 'value' }
      fallback.store_translations('en', 'key' => nested)
      subject.translate('en', 'key', :default => 'Unexpected').should == nested
      sync['en.key'].should be_nil
    end

    it "looks up an array of defaults" do
      fallback.store_translations('en', 'key' => { 'one' => 'Expected' })
      subject.translate('en', 'key.three', :default => [:"key.two", :"key.one"]).
        should include('Expected')
    end
  end
end
