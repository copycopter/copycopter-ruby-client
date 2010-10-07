require 'spec_helper'

describe CopycopterClient::I18nBackend do
  let(:sync) { {} }

  def build_backend(config = {})
    default_config = CopycopterClient::Configuration.new.to_hash
    CopycopterClient::I18nBackend.new(sync, default_config.update(config))
  end

  subject { build_backend }

  it "does nothing when reloaded" do
    lambda { subject.reload! }.should_not raise_error
  end

  it "includes the base i18n backend" do
    should be_kind_of(I18n::Backend::Base)
  end

  it "looks up a key in sync" do
    value = 'hello'
    sync['en.prefix.test.key'] = value

    backend = build_backend(:public => true)

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

  it "adds edit links in development" do
    backend = build_backend(:public   => false,
                            :host     => 'example.com',
                            :protocol => 'https',
                            :port     => 443,
                            :api_key  => 'xyzabc')
    backend.translate('en', 'test.key', :default => 'default').
      should include(%{<a href="https://example.com/edit/xyzabc/en.test.key" target="_blank">Edit</a>})
  end

  it "doesn't add edit links in public" do
    backend = build_backend(:public   => true)
    backend.translate('en', 'test.key', :default => 'default').
      should_not include("<a href")
  end
end
