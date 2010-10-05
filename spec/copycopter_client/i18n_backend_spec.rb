require 'spec_helper'

describe CopycopterClient::I18nBackend do
  let(:sync) { {} }
  subject { CopycopterClient::I18nBackend.new(sync) }

  it "does nothing when reloaded" do
    lambda { subject.reload! }.should_not raise_error
  end

  it "includes the base i18n backend" do
    should be_kind_of(I18n::Backend::Base)
  end

  it "looks up a key in sync" do
    value = 'hello'
    sync['en.prefix.test.key'] = value

    subject.translate('en', 'test.key', :scope => 'prefix').should == value
  end

  it "finds available locales" do
    sync['en.key'] = ''
    sync['fr.key'] = ''

    subject.available_locales.should =~ %w(en fr)
  end

  it "queues missing keys" do
    default = 'default value'

    subject.translate('en', 'test.key', :default => default)

    sync['en.test.key'].should == default
  end
end
