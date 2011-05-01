require 'spec_helper'

describe CopycopterClient::Sync do
  include DefinesConstants

  let(:client) { FakeClient.new }

  def build_sync(config = {})
    config[:logger] ||= FakeLogger.new
    default_config = CopycopterClient::Configuration.new.to_hash
    sync = CopycopterClient::Sync.new(client, default_config.update(config))
    @syncs << sync
    sync
  end

  before do
    @syncs = []
  end

  after do
    @syncs.each { |sync| sync.stop }
  end

  it "provides access to downloaded data" do
    client['en.test.key']       = 'expected'
    client['en.test.other_key'] = 'expected'

    sync = build_sync

    sync.start

    sync['en.test.key'].should == 'expected'
    sync.keys.should =~ %w(en.test.key en.test.other_key)
  end

  it "it polls after being started" do
    sync = build_sync(:polling_delay => 1)
    sync.start

    sync['test.key'].should be_nil

    client['test.key'] = 'value'
    sleep(2)

    sync['test.key'].should == 'value'
  end

  it "stops polling when stopped" do
    sync = build_sync(:polling_delay => 1)
    sync.start

    sync['test.key'].should be_nil

    sync.stop

    client['test.key'] = 'value'
    sleep(2)

    sync['test.key'].should be_nil
  end

  it "doesn't upload without changes" do
    sync = build_sync(:polling_delay => 1)
    sync.start
    sleep(2)
    client.should_not be_uploaded
  end

  it "uploads changes when polling" do
    sync = build_sync(:polling_delay => 1)
    sync.start

    sync['test.key'] = 'test value'
    sleep(2)

    client.uploaded.should == { 'test.key' => 'test value' }
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

  it "handles connection errors when polling" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:upload).raises(CopycopterClient::ConnectionError.new(failure))
    sync = build_sync(:polling_delay => 1, :logger => logger)

    sync['upload.key'] = 'upload'
    sync.start
    sleep(2)

    logger.should have_entry(:error, failure),
                  logger.entries.inspect

    client['test.key'] = 'test value'
    sleep(2)

    sync['test.key'].should == 'test value'
  end

  it "handles an invalid api key" do
    failure = "server is napping"
    logger = FakeLogger.new
    client.stubs(:upload).raises(CopycopterClient::InvalidApiKey.new(failure))
    sync = build_sync(:polling_delay => 1, :logger => logger)

    sync['upload.key'] = 'upload'
    sync.start
    sleep(2)

    logger.should have_entry(:error, failure),
                  logger.entries.inspect

    client['test.key'] = 'test value'
    sleep(2)

    sync['test.key'].should be_nil
  end

  it "blocks until the first download is complete" do
    logger = FakeLogger.new
    logger.stubs(:flush)
    client.delay = 1
    sync = build_sync(:logger => logger)

    sync.start

    finished = false
    Thread.new do
      sync.wait_for_download
      finished = true
    end

    logger.should have_entry(:info, "Waiting for first sync")
    logger.should have_received(:flush)
    finished.should == false

    sleep(3)

    finished.should == true
  end

  it "doesn't block if the first download fails" do
    client.delay = 1
    client.stubs(:upload).raises(StandardError.new("Failure"))
    sync = build_sync

    sync['test.key'] = 'value'
    sync.start

    finished = false
    Thread.new do
      sync.wait_for_download
      finished = true
    end

    finished.should == false

    sleep(4)

    finished.should == true
  end

  it "doesn't block before starting" do
    logger = FakeLogger.new
    sync = build_sync(:polling_delay => 3, :logger => logger)

    finished = false
    Thread.new do
      sync.wait_for_download
      finished = true
    end

    sleep(1)

    finished.should == true
    logger.should_not have_entry(:info, "Waiting for first sync")
  end

  it "logs an error if the background thread can't start" do
    Thread.stubs(:new => nil)
    logger = FakeLogger.new

    build_sync(:logger => logger).start

    logger.should have_entry(:error, "Couldn't start poller thread")
  end

  it "flushes the log when polling" do
    logger = FakeLogger.new
    logger.stubs(:flush)
    sync = build_sync(:polling_delay => 1, :logger =>  logger)

    sync.start
    sleep(2)

    logger.should have_received(:flush).at_least_once
  end

  it "doesn't return blank copy" do
    client['en.test.key'] = ''
    sync = build_sync(:polling_delay => 1)

    sync.start
    sleep(2)

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
    let(:sync) { build_sync(:polling_delay => 0.1) }

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

  it "starts from the top-level constant" do
    sync = build_sync
    CopycopterClient.sync = sync
    sync.stubs(:start)

    CopycopterClient.start_sync

    sync.should have_received(:start)
  end

  it "flushes from the top level" do
    sync = build_sync
    CopycopterClient.sync = sync
    sync.stubs(:flush)

    CopycopterClient.flush

    sync.should have_received(:flush)
  end
end

