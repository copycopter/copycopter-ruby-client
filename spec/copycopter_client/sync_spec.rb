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

  after { @syncs.each { |sync| sync.stop } }

  it "syncs when the process terminates" do
    api_key = "12345"
    FakeCopycopterApp.add_project api_key
    pid = fork do
      config = { :logger => FakeLogger.new, :polling_delay => 86400, :api_key => api_key }
      default_config = CopycopterClient::Configuration.new.to_hash.update(config)
      real_client = CopycopterClient::Client.new(default_config)
      sync = CopycopterClient::Sync.new(real_client, default_config)
      sync.start
      sleep 2
      sync['test.key'] = 'value'
      Signal.trap("INT") { exit }
      sleep
    end
    sleep 3
    Process.kill("INT", pid)
    Process.wait
    project = FakeCopycopterApp.project(api_key)
    project.draft['test.key'].should == 'value'
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
    sync = build_sync(:polling_delay => 86400)
    sync.start
    sleep 2
    sync['test.key'] = 'test value'
    sync.flush
    sleep(2)

    client.uploaded.should == { 'test.key' => 'test value' }
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

  it "starts after spawning when using passenger" do
    logger = FakeLogger.new
    passenger = define_constant('PhusionPassenger', FakePassenger.new)
    passenger.become_master
    sync = build_sync(:polling_delay => 1, :logger => logger)

    sync.start
    sleep(2)

    client.should_not be_downloaded
    logger.should have_entry(:info, "Registered Phusion Passenger fork hook")

    passenger.spawn
    sleep(2)

    client.should be_downloaded
    logger.should have_entry(:info, "Starting poller"),
                  "Got entries: #{logger.entries.inspect}"
  end

  it "flushes after running a resque job" do
    define_constant('Resque', Module.new)
    job = define_constant('Resque::Job', FakeResqueJob).new(:key => 'test.key', :value => 'all your base')

    api_key = "12345"
    FakeCopycopterApp.add_project api_key
    logger = FakeLogger.new

    config = { :logger => logger, :polling_delay => 86400, :api_key => api_key }
    default_config = CopycopterClient::Configuration.new.to_hash.update(config)
    real_client = CopycopterClient::Client.new(default_config)
    sync = CopycopterClient::Sync.new(real_client, default_config)
    CopycopterClient.sync = sync
    job.sync = sync

    sync.start
    sleep(2)

    logger.should have_entry(:info, "Registered Resque after_perform hook")

    if fork
      Process.wait
    else
      job.perform
      exit!
    end
    sleep(2)

    project = FakeCopycopterApp.project(api_key)
    project.draft['test.key'].should == 'all your base'

  end

  it "starts after spawning when using unicorn" do
    logger = FakeLogger.new
    define_constant('Unicorn', Module.new)
    unicorn = define_constant('Unicorn::HttpServer', FakeUnicornServer).new
    unicorn.become_master
    sync = build_sync(:polling_delay => 1, :logger => logger)
    CopycopterClient.sync = sync

    sync.start
    sleep(2)

    client.should_not be_downloaded
    logger.should have_entry(:info, "Registered Unicorn fork hook")

    unicorn.spawn
    sleep(2)

    client.should be_downloaded
    logger.should have_entry(:info, "Starting poller")
  end

  it "blocks until the first download is complete" do
    logger = FakeLogger.new
    client.delay = 1
    sync = build_sync(:logger => logger)

    sync.start

    finished = false
    Thread.new do
      sync.wait_for_download
      finished = true
    end

    logger.should have_entry(:info, "Waiting for first sync")
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

  describe "given locked mutex" do
    Spec::Matchers.define :finish_after_unlocking do |mutex|
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

