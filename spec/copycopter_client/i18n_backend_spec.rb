require 'spec_helper'

describe CopycopterClient::I18nBackend do
  let(:cache) { {} }

  def build_backend
    backend = CopycopterClient::I18nBackend.new(cache)
    I18n.backend = backend
    backend
  end

  before do
    @default_backend = I18n.backend
    cache.stubs(:wait_for_download)
  end

  after { I18n.backend = @default_backend }

  subject { build_backend }

  it "reloads locale files and waits for the download to complete" do
    I18n.stubs(:load_path => [])
    subject.reload!
    subject.translate('en', 'test.key', :default => 'something')

    cache.should have_received(:wait_for_download)
    I18n.should have_received(:load_path)
  end

  it "includes the base i18n backend" do
    should be_kind_of(I18n::Backend::Base)
  end

  it "looks up a key in cache" do
    value = 'hello'
    cache['en.prefix.test.key'] = value

    backend = build_backend

    backend.translate('en', 'test.key', :scope => 'prefix').should == value
  end

  it "finds available locales from locale files and cache" do
    YAML.stubs(:load_file => { 'es' => { 'key' => 'value' } })
    I18n.stubs(:load_path => ["test.yml"])

    cache['en.key'] = ''
    cache['fr.key'] = ''

    subject.available_locales.should =~ [:en, :es, :fr]
  end

  it "queues missing keys with default" do
    default = 'default value'

    subject.translate('en', 'test.key', :default => default).should == default

    cache['en.test.key'].should == default
  end

  it "queues missing keys without default" do
    expect { subject.translate('en', 'test.key') }.
      to throw_symbol(:exception)

    cache['en.test.key'].should == ""
  end

  it "queues missing keys with scope" do
    default = 'default value'

    subject.translate('en', 'key', :default => default, :scope => ['test']).
      should == default

    cache['en.test.key'].should == default
  end

  it "marks strings as html safe" do
    cache['en.test.key'] = FakeHtmlSafeString.new("Hello")
    backend = build_backend
    backend.translate('en', 'test.key').should be_html_safe
  end

  it "looks up an array of defaults" do
    cache['en.key.one'] = "Expected"
    backend = build_backend
    backend.translate('en', 'key.three', :default => [:"key.two", :"key.one"]).
      should == 'Expected'
  end

  describe "with stored translations" do
    subject { build_backend }

    it "uses stored translations as a default" do
      subject.store_translations('en', 'test' => { 'key' => 'Expected' })
      subject.translate('en', 'test.key', :default => 'Unexpected').
        should include('Expected')
      cache['en.test.key'].should == 'Expected'
    end

    it "preserves interpolation markers in the stored translation" do
      subject.store_translations('en', 'test' => { 'key' => '%{interpolate}' })
      subject.translate('en', 'test.key', :interpolate => 'interpolated').
        should include('interpolated')
      cache['en.test.key'].should == '%{interpolate}'
    end

    it "uses the default if the stored translations don't have the key" do
      subject.translate('en', 'test.key', :default => 'Expected').
        should include('Expected')
    end

    it "uses the cached key when present" do
      subject.store_translations('en', 'test' => { 'key' => 'Unexpected' })
      cache['en.test.key'] = 'Expected'
      subject.translate('en', 'test.key', :default => 'default').
        should include('Expected')
    end

    it "stores a nested hash" do
      nested = { :nested => 'value' }
      subject.store_translations('en', 'key' => nested)
      subject.translate('en', 'key', :default => 'Unexpected').should == nested
      cache['en.key.nested'].should == 'value'
    end

    it "returns an array directly without storing" do
      array = ['value']
      subject.store_translations('en', 'key' => array)
      subject.translate('en', 'key', :default => 'Unexpected').should == array
      cache['en.key'].should be_nil
    end

    it "looks up an array of defaults" do
      subject.store_translations('en', 'key' => { 'one' => 'Expected' })
      subject.translate('en', 'key.three', :default => [:"key.two", :"key.one"]).
        should include('Expected')
    end
  end

  describe "with a backend using fallbacks" do
    subject { build_backend }

    before do
      CopycopterClient::I18nBackend.class_eval do
        include I18n::Backend::Fallbacks
      end
    end

    it "queues missing keys with default" do
      default = 'default value'

      subject.translate('en', 'test.key', :default => default).should == default

      cache['en.test.key'].should == default
    end
  end
end
