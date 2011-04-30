require 'spec_helper'

describe CopycopterClient::Sync do
  let(:client) { FakeClient.new }

  def build_sync(config = {})
    config[:logger] ||= FakeLogger.new
    default_config = CopycopterClient::Configuration.new.to_hash
    CopycopterClient::Sync.new(client, default_config.update(config))
  end

  it "provides access to downloaded data" do
    client['en.test.key']       = 'expected'
    client['en.test.other_key'] = 'expected'

    sync = build_sync

    sync.download

    sync['en.test.key'].should == 'expected'
    sync.keys.should =~ %w(en.test.key en.test.other_key)
  end

  it "doesn't upload without changes" do
    sync = build_sync
    sync.flush
    client.should_not be_uploaded
  end

  it "uploads changes when flushed" do
    sync = build_sync
    sync['test.key'] = 'test value'

    sync.flush

    client.uploaded.should == { 'test.key' => 'test value' }
  end

  it "downloads changes" do
    client['test.key'] = 'test value'
    sync = build_sync

    sync.download

    sync['test.key'].should == 'test value'
  end

  it "downloads and uploads when synced" do
    sync = build_sync
    client['test.key'] = 'test value'
    sync['other.key'] = 'other value'

    sync.sync

    client.uploaded.should == { 'other.key' => 'other value' }
    sync['test.key'].should == 'test value'
  end

  it "handles connection errors when flushing" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:upload).raises(CopycopterClient::ConnectionError.new(failure))
    sync = build_sync(:logger => logger)
    sync['upload.key'] = 'upload'

    sync.flush

    logger.should have_entry(:error, failure)
  end

  it "handles connection errors when downloading" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:download).raises(CopycopterClient::ConnectionError.new(failure))
    sync = build_sync(:logger => logger)

    sync.download

    logger.should have_entry(:error, failure)
  end

  it "blocks until the first download is complete" do
    logger = FakeLogger.new
    logger.stubs(:flush)
    client.delay = 0.5
    sync = build_sync(:logger => logger)

    Thread.new { sync.download }

    finished = false
    Thread.new do
      sync.wait_for_download
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
    sync = build_sync

    Thread.new { sync.download }

    finished = false
    Thread.new do
      sync.wait_for_download
      finished = true
    end

    sleep(1)

    expect { sync.download }.to raise_error(StandardError, "Failure")
    finished.should == true
  end

  it "doesn't block before downloading" do
    logger = FakeLogger.new
    sync = build_sync(:logger => logger)

    finished = false
    Thread.new do
      sync.wait_for_download
      finished = true
    end

    sleep(1)

    finished.should == true
    logger.should_not have_entry(:info, "Waiting for first sync")
  end

  it "doesn't return blank copy" do
    client['en.test.key'] = ''
    sync = build_sync

    sync.download

    sync['en.test.key'].should be_nil
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
    let(:sync) { build_sync }

    before do
      mutex.lock
      Mutex.stubs(:new => mutex)
    end

    it "synchronizes read access to keys between threads" do
      Thread.new { sync['test.key'] }.should finish_after_unlocking(mutex)
    end

    it "synchronizes read access to the key list between threads" do
      Thread.new { sync.keys }.should finish_after_unlocking(mutex)
    end

    it "synchronizes write access to keys between threads" do
      Thread.new { sync['test.key'] = 'value' }.should finish_after_unlocking(mutex)
    end
  end

  it "flushes from the top level" do
    sync = build_sync
    CopycopterClient.sync = sync
    sync.stubs(:flush)

    CopycopterClient.flush

    sync.should have_received(:flush)
  end
end

