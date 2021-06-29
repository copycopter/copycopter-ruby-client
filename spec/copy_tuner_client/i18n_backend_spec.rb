require 'spec_helper'

describe CopyTunerClient::I18nBackend do
  let(:cache) { {} }

  def build_backend
    backend = CopyTunerClient::I18nBackend.new(cache)
    I18n.backend = backend
    backend
  end

  before do
    @default_backend = I18n.backend
    allow(cache).to receive(:wait_for_download)
  end

  after { I18n.backend = @default_backend }

  subject { build_backend }

  it "reloads locale files and waits for the download to complete" do
    expect(I18n).to receive(:load_path).and_return([])
    expect(cache).to receive(:wait_for_download)
    subject.reload!
    subject.translate('en', 'test.key', :default => 'something')
  end

  it "includes the base i18n backend" do
    is_expected.to be_kind_of(I18n::Backend::Base)
  end

  it "looks up a key in cache" do
    value = 'hello'
    cache['en.prefix.test.key'] = value

    backend = build_backend

    expect(backend.translate('en', 'test.key', :scope => 'prefix')).to eq(value)
  end

  it "finds available locales from locale files and cache" do
    allow(YAML).to receive(:load_file).and_return({ 'es' => { 'key' => 'value' } })
    allow(I18n).to receive(:load_path).and_return(["test.yml"])

    cache['en.key'] = ''
    cache['fr.key'] = ''

    expect(subject.available_locales).to match_array([:en, :es, :fr])
  end

  it "queues missing keys with default" do
    default = 'default value'

    expect(subject.translate('en', 'test.key', :default => default)).to eq(default)

    expect(cache['en.test.key']).to eq(default)
  end

  it "queues missing keys with default string in an array" do
    default = 'default value'

    expect(subject.translate('en', 'test.key', :default => [default])).to eq(default)

    expect(cache['en.test.key']).to eq(default)
  end

  it "queues missing keys without default" do
    expect { subject.translate('en', 'test.key') }.
      to throw_symbol(:exception)

    expect(cache).to have_key 'en.test.key'
    expect(cache['en.test.key']).to be_nil
  end

  it "queues missing keys with scope" do
    default = 'default value'

    expect(subject.translate('en', 'key', :default => default, :scope => ['test'])).
      to eq(default)

    expect(cache['en.test.key']).to eq(default)
  end

  it "does not queues missing keys with a symbol of default" do
    cache['en.key.one'] = "Expected"

    expect(subject.translate('en', 'key.three', :default => :"key.one")).to eq 'Expected'

    expect(cache).to have_key 'en.key.three'
    expect(cache['en.key.three']).to be_nil

    expect(subject.translate('en', 'key.three', :default => :"key.one")).to eq 'Expected'
  end

  it "does not queues missing keys with an array of default" do
    cache['en.key.one'] = "Expected"

    expect(subject.translate('en', 'key.three', :default => [:"key.two", :"key.one"])).to eq 'Expected'

    expect(cache).to have_key 'en.key.three'
    expect(cache['en.key.three']).to be_nil

    expect(subject.translate('en', 'key.three', :default => [:"key.two", :"key.one"])).to eq 'Expected'
  end

  it "queues missing keys with interpolation" do
    default = 'default %{interpolate}'

    expect(subject.translate('en', 'test.key', :default => default, :interpolate => 'interpolated')).to eq 'default interpolated'

    expect(cache['en.test.key']).to eq 'default %{interpolate}'
  end

  it "marks strings as html safe" do
    cache['en.test.key'] = FakeHtmlSafeString.new("Hello")
    backend = build_backend
    expect(backend.translate('en', 'test.key')).to be_html_safe
  end

  it "looks up an array of defaults" do
    cache['en.key.one'] = "Expected"
    backend = build_backend
    expect(backend.translate('en', 'key.three', :default => [:"key.two", :"key.one"])).
      to eq('Expected')
  end

  context "html_escape option is true" do
    before do
      CopyTunerClient.configure do |configuration|
        configuration.html_escape = true
        configuration.client = FakeClient.new
      end
    end

    it "do not marks strings as html safe" do
      cache['en.test.key'] = FakeHtmlSafeString.new("Hello")
      backend = build_backend
      expect(backend.translate('en', 'test.key')).not_to be_html_safe
    end
  end

  context 'non-string key' do
    it 'Not to be registered in the cache' do
      expect { subject.translate('en', {}) }.to throw_symbol(:exception)
      expect(cache).not_to have_key 'en.{}'
    end
  end

  describe "with stored translations" do
    subject { build_backend }

    it "uses stored translations as a default" do
      subject.store_translations('en', 'test' => { 'key' => 'Expected' })
      expect(subject.translate('en', 'test.key', :default => 'Unexpected')).
        to include('Expected')
      expect(cache['en.test.key']).to eq('Expected')
    end

    it "preserves interpolation markers in the stored translation" do
      subject.store_translations('en', 'test' => { 'key' => '%{interpolate}' })
      expect(subject.translate('en', 'test.key', :interpolate => 'interpolated')).
        to include('interpolated')
      expect(cache['en.test.key']).to eq('%{interpolate}')
    end

    it "uses the default if the stored translations don't have the key" do
      expect(subject.translate('en', 'test.key', :default => 'Expected')).
        to include('Expected')
    end

    it "uses the cached key when present" do
      subject.store_translations('en', 'test' => { 'key' => 'Unexpected' })
      cache['en.test.key'] = 'Expected'
      expect(subject.translate('en', 'test.key', :default => 'default')).
        to include('Expected')
    end

    it "stores a nested hash" do
      nested = { :nested => 'value' }
      subject.store_translations('en', 'key' => nested)
      expect(subject.translate('en', 'key', :default => 'Unexpected')).to eq(nested)
      expect(cache['en.key.nested']).to eq('value')
    end

    it "returns an array directly without storing" do
      array = ['value']
      subject.store_translations('en', 'key' => array)
      expect(subject.translate('en', 'key', :default => 'Unexpected')).to eq(array)
      expect(cache['en.key']).to be_nil
    end

    it "looks up an array of defaults" do
      subject.store_translations('en', 'key' => { 'one' => 'Expected' })
      expect(subject.translate('en', 'key.three', :default => [:"key.two", :"key.one"])).
        to include('Expected')
    end
  end

  describe "with a backend using fallbacks" do
    subject { build_backend }

    before do
      CopyTunerClient::I18nBackend.class_eval do
        include I18n::Backend::Fallbacks
      end
    end

    it "queues missing keys with blank string" do
      default = 'default value'
      expect(subject.translate('en', 'test.key', :default => default)).to eq(default)

      # default と Fallbacks を併用した場合、キャッシュにデフォルト値は入らない仕様に変えた
      # その仕様にしないと、うまく Fallbacks の処理が動かないため
      expect(cache).to have_key 'en.test.key'
      expect(cache['en.test.key']).to be_nil
    end
  end
end
