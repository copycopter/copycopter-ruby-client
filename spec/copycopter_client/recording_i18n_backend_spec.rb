require 'spec_helper'
require 'copycopter_client/recording_i18n_backend'

describe CopycopterClient::RecordingI18nBackend do

  it "returns a list of keys translated during the block" do
    base_backend = I18n::Backend::Simple.new
    base_backend.store_translations('en', 'test' => { 'one' => 'one', 'two' => 'two' })
    backend = CopycopterClient::RecordingI18nBackend.new(base_backend)

    result = backend.record do
      backend.translate('en', 'test.one').should == 'one'
      backend.translate('en', 'test.two').should == 'two'
    end

    result.should == %w(test.one test.two)
  end

  it "caches keys within a scope" do
    base_backend = I18n::Backend::Simple.new
    base_backend.store_translations('en', 'test' => { 'one' => 'one' })
    backend = CopycopterClient::RecordingI18nBackend.new(base_backend)

    result = backend.record do
      backend.translate('en', 'one', :scope => ['test']).should == 'one'
    end

    result.should == %w(test.one)
  end

  it "caches keys triggered by default lookups" do
    base_backend = I18n::Backend::Simple.new
    base_backend.store_translations('en', 'test' => { 'two' => 'result' })
    backend = CopycopterClient::RecordingI18nBackend.new(base_backend)
    I18n.backend = backend

    result = backend.record do
      backend.translate('en', 'test.one', :default => [:'test.two']).should == 'result'
    end

    result.should == %w(test.one test.two)
  end

  it "only records a key once" do
    base_backend = I18n::Backend::Simple.new
    base_backend.store_translations('en', 'test' => 'value')
    backend = CopycopterClient::RecordingI18nBackend.new(base_backend)

    result = backend.record do
      2.times { backend.translate('en', 'test') }
    end

    result.should == %w(test)
  end

  it "reloads" do
    base_backend = stub('base_backend', :reload! => false)
    backend = CopycopterClient::RecordingI18nBackend.new(base_backend)

    backend.reload!

    base_backend.should have_received(:reload!)
  end

  it "returns locales" do
    base_backend = stub('base_backend', :available_locales => %w(en fr))
    backend = CopycopterClient::RecordingI18nBackend.new(base_backend)

    backend.available_locales.should == %w(en fr)
  end

end
