require 'spec_helper'

describe CopycopterClient::Cache do
  let(:client) { FakeClient.new }

  def build_cache(config = {})
    config[:logger] ||= FakeLogger.new
    default_config = CopycopterClient::Configuration.new.to_hash
    CopycopterClient::Cache.new(client, default_config.update(config))
  end

  it "provides access to downloaded data" do
    client['en.test.key']       = 'expected'
    client['en.test.other_key'] = 'expected'

    cache = build_cache

    cache.download

    cache['en.test.key'].should == 'expected'
    cache.keys.should =~ %w(en.test.key en.test.other_key)
  end

  it "doesn't upload without changes" do
    cache = build_cache
    cache.flush
    client.should_not be_uploaded
  end

  it "uploads changes when flushed" do
    cache = build_cache
    cache['test.key'] = 'test value'

    cache.flush

    client.uploaded.should == { 'test.key' => 'test value' }
  end

  it "downloads changes" do
    client['test.key'] = 'test value'
    cache = build_cache

    cache.download

    cache['test.key'].should == 'test value'
  end

  it "downloads and uploads when synced" do
    cache = build_cache
    client['test.key'] = 'test value'
    cache['other.key'] = 'other value'

    cache.sync

    client.uploaded.should == { 'other.key' => 'other value' }
    cache['test.key'].should == 'test value'
  end

  it "handles connection errors when flushing" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:upload).raises(CopycopterClient::ConnectionError.new(failure))
    cache = build_cache(:logger => logger)
    cache['upload.key'] = 'upload'

    cache.flush

    logger.should have_entry(:error, failure)
  end

  it "handles connection errors when downloading" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:download).raises(CopycopterClient::ConnectionError.new(failure))
    cache = build_cache(:logger => logger)

    cache.download

    logger.should have_entry(:error, failure)
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

    finished.should == true
    logger.should have_entry(:info, "Waiting for first download")
    logger.should have_received(:flush)
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
    finished.should == true
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

    finished.should == true
    logger.should_not have_entry(:info, "Waiting for first download")
  end

  it "doesn't return blank copy" do
    client['en.test.key'] = ''
    cache = build_cache

    cache.download

    cache['en.test.key'].should be_nil
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
      Thread.new { cache['test.key'] }.should finish_after_unlocking(mutex)
    end

    it "synchronizes read access to the key list between threads" do
      Thread.new { cache.keys }.should finish_after_unlocking(mutex)
    end

    it "synchronizes write access to keys between threads" do
      Thread.new { cache['test.key'] = 'value' }.should finish_after_unlocking(mutex)
    end
  end

  it "flushes from the top level" do
    cache = build_cache
    CopycopterClient.configure do |config|
      config.cache = cache
    end
    cache.stubs(:flush)

    CopycopterClient.flush

    cache.should have_received(:flush)
  end

  describe "#export" do
    before do
      save_blurbs
      @cache = build_cache
      @cache.download
    end

    let(:save_blurbs) {}

    it "can be invoked from the top-level constant" do
      CopycopterClient.configure do |config|
        config.cache = @cache
      end
      @cache.stubs(:export)

      CopycopterClient.export

      @cache.should have_received(:export)
    end

    it "returns no yaml with no blurb keys" do
      @cache.export.should == nil
    end

    context "with single-level blurb keys" do
      let(:save_blurbs) do
        client['key']       = 'test value'
        client['other_key'] = 'other test value'
      end

      it "returns blurbs as yaml" do
        exported = YAML.load(@cache.export)
        exported['key'].should == 'test value'
        exported['other_key'].should == 'other test value'
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
        exported['en']['test']['key'].should == 'en test value'
        exported['en']['test']['other_key'].should == 'en other test value'
        exported['fr']['test']['key'].should == 'fr test value'
      end
    end

    context "with conflicting blurb keys" do
      let(:save_blurbs) do
        client['en.test']     = 'test value'
        client['en.test.key'] = 'other test value'
      end

      it "retains the new key" do
        exported = YAML.load(@cache.export)
        exported['en']['test']['key'].should == 'other test value'
      end
    end
  end
end

