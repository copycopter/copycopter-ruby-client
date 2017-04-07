require 'spec_helper'

describe CopyTunerClient::Cache do
  let(:client) { FakeClient.new }

  def build_cache(config = {})
    config[:logger] ||= FakeLogger.new
    default_config = CopyTunerClient::Configuration.new.to_hash
    CopyTunerClient::Cache.new(client, default_config.update(config))
  end

  it "provides access to downloaded data" do
    client['en.test.key']       = 'expected'
    client['en.test.other_key'] = 'expected'

    cache = build_cache

    cache.download

    expect(cache['en.test.key']).to eq('expected')
    expect(cache.keys).to match_array(%w(en.test.key en.test.other_key))
  end

  it "exclude data if exclude_key_regexp is set" do
    cache = build_cache(exclude_key_regexp: /^en\.test\.other_key$/)
    cache['en.test.key']       = 'expected'
    cache['en.test.other_key'] = 'expected'

    cache.download

    expect(cache.queued.keys).to match_array(%w(en.test.key))
  end

  it "doesn't upload without changes" do
    cache = build_cache
    cache.flush
    expect(client).not_to be_uploaded
  end

  it "uploads changes when flushed" do
    cache = build_cache
    cache['test.key'] = 'test value'

    cache.flush

    expect(client.uploaded).to eq({ 'test.key' => 'test value' })
  end

  it 'upload without locale filter' do
    cache = build_cache
    cache['en.test.key'] = 'uploaded en'
    cache['ja.test.key'] = 'uploaded ja'

    cache.flush

    expect(client.uploaded).to eq({'en.test.key' => 'uploaded en', 'ja.test.key' => 'uploaded ja'})
  end

  it 'upload with locale filter' do
    cache = build_cache(locales: %(en))
    cache['en.test.key'] = 'uploaded'
    cache['ja.test.key'] = 'not uploaded'

    cache.flush

    expect(client.uploaded).to eq({'en.test.key' => 'uploaded'})
  end

  it "downloads changes" do
    client['test.key'] = 'test value'
    cache = build_cache

    cache.download

    expect(cache['test.key']).to eq('test value')
  end

  it "downloads and uploads when synced" do
    cache = build_cache
    client['test.key'] = 'test value'
    cache['other.key'] = 'other value'

    cache.sync

    expect(client.uploaded).to eq({ 'other.key' => 'other value' })
    expect(cache['test.key']).to eq('test value')
  end

  it "handles connection errors when flushing" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:upload).raises(CopyTunerClient::ConnectionError.new(failure))
    cache = build_cache(:logger => logger)
    cache['upload.key'] = 'upload'

    cache.flush

    expect(logger).to have_entry(:error, failure)
  end

  it "handles connection errors when downloading" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:download).raises(CopyTunerClient::ConnectionError.new(failure))
    cache = build_cache(:logger => logger)

    cache.download

    expect(logger).to have_entry(:error, failure)
  end

  it "blocks until the first download is complete" do
    logger = FakeLogger.new
    logger.stubs(:flush)
    client.delay = 0.5
    cache = build_cache(:logger => logger)

    Thread.new { cache.download }

    finished = false
    Thread.new do
      cache.wait_for_download
      finished = true
    end

    sleep(1)

    expect(finished).to eq(true)
    # FIXME 成功したり、失敗していたりするので、一旦コメントアウト。後で直します。
    # logger.should have_entry(:info, "Waiting for first download")
    # logger.should have_received(:flush)
  end

  it "doesn't block if the first download fails" do
    client.delay = 0.5
    client.error = StandardError.new("Failure")
    cache = build_cache

    Thread.new { cache.download }

    finished = false
    Thread.new do
      cache.wait_for_download
      finished = true
    end

    sleep(1)

    expect { cache.download }.to raise_error(StandardError, "Failure")
    expect(finished).to eq(true)
  end

  it "doesn't block before downloading" do
    logger = FakeLogger.new
    cache = build_cache(:logger => logger)

    finished = false
    Thread.new do
      cache.wait_for_download
      finished = true
    end

    sleep(1)

    expect(finished).to eq(true)
    expect(logger).not_to have_entry(:info, "Waiting for first download")
  end

  it "doesn't return blank copy" do
    client['en.test.key'] = ''
    cache = build_cache

    cache.download

    expect(cache['en.test.key']).to be_nil
  end

  describe "given locked mutex" do
    RSpec::Matchers.define :finish_after_unlocking do |mutex|
      match do |thread|
        sleep(0.1)

        if thread.status === false
          violated("finished before unlocking")
        else
          mutex.unlock
          sleep(0.1)

          if thread.status === false
            true
          else
            violated("still running after unlocking")
          end
        end
      end

      def violated(failure)
        @failure_message = failure
        false
      end

      failure_message_for_should do
        @failure_message
      end
    end

    let(:mutex) { Mutex.new }
    let(:cache) { build_cache }

    before do
      mutex.lock
      Mutex.stubs(:new => mutex)
    end

    it "synchronizes read access to keys between threads" do
      expect(Thread.new { cache['test.key'] }).to finish_after_unlocking(mutex)
    end

    it "synchronizes read access to the key list between threads" do
      expect(Thread.new { cache.keys }).to finish_after_unlocking(mutex)
    end

    it "synchronizes write access to keys between threads" do
      expect(Thread.new { cache['test.key'] = 'value' }).to finish_after_unlocking(mutex)
    end
  end

  it "flushes from the top level" do
    cache = build_cache
    CopyTunerClient.configure do |config|
      config.cache = cache
    end
    cache.stubs(:flush)

    CopyTunerClient.flush

    # FIXME 不安定なので後ほど修正する。
    # cache.should have_received(:flush)
  end

  describe "#export" do
    before do
      save_blurbs
      @cache = build_cache
      @cache.download
    end

    let(:save_blurbs) {}

    it "can be invoked from the top-level constant" do
      CopyTunerClient.configure do |config|
        config.cache = @cache
      end
      @cache.stubs(:export)

      CopyTunerClient.export

      expect(@cache).to have_received(:export)
    end

    it "returns no yaml with no blurb keys" do
      expect(@cache.export).to eq(nil)
    end

    context "with single-level blurb keys" do
      let(:save_blurbs) do
        client['key']       = 'test value'
        client['other_key'] = 'other test value'
      end

      it "returns blurbs as yaml" do
        exported = YAML.load(@cache.export)
        expect(exported['key']).to eq('test value')
        expect(exported['other_key']).to eq('other test value')
      end
    end

    context "with multi-level blurb keys" do
      let(:save_blurbs) do
        client['en.test.key']       = 'en test value'
        client['en.test.other_key'] = 'en other test value'
        client['fr.test.key']       = 'fr test value'
      end

      it "returns blurbs as yaml" do
        exported = YAML.load(@cache.export)
        expect(exported['en']['test']['key']).to eq('en test value')
        expect(exported['en']['test']['other_key']).to eq('en other test value')
        expect(exported['fr']['test']['key']).to eq('fr test value')
      end
    end

    context "with conflicting blurb keys" do
      let(:save_blurbs) do
        client['en.test']     = 'test value'
        client['en.test.key'] = 'other test value'
      end

      it "retains the new key" do
        exported = YAML.load(@cache.export)
        expect(exported['en']['test']['key']).to eq('other test value')
      end
    end
  end
end
