require 'spec_helper'

describe CopycopterClient::Poller do
  POLLING_DELAY = 0.5

  let(:client) { FakeClient.new }
  let(:cache) { CopycopterClient::Cache.new(client, :logger => FakeLogger.new) }

  def build_poller(config = {})
    config[:logger] ||= FakeLogger.new
    config[:polling_delay] = POLLING_DELAY
    default_config = CopycopterClient::Configuration.new.to_hash
    poller = CopycopterClient::Poller.new(cache, default_config.update(config))
    @pollers << poller
    poller
  end

  def wait_for_next_sync
    sleep(POLLING_DELAY * 3)
  end

  before do
    @pollers = []
  end

  after do
    @pollers.each { |poller| poller.stop }
  end

  it "it polls after being started" do
    poller = build_poller
    poller.start

    client['test.key'] = 'value'
    wait_for_next_sync

    cache['test.key'].should == 'value'
  end

  it "it doesn't poll before being started" do
    poller = build_poller
    client['test.key'] = 'value'

    wait_for_next_sync

    cache['test.key'].should be_nil
  end

  it "stops polling when stopped" do
    poller = build_poller

    poller.start
    poller.stop

    client['test.key'] = 'value'
    wait_for_next_sync

    cache['test.key'].should be_nil
  end

  it "stops polling with an invalid api key" do
    failure = "server is napping"
    logger = FakeLogger.new
    cache.stubs(:download).raises(CopycopterClient::InvalidApiKey.new(failure))
    poller = build_poller(:logger => logger)

    cache['upload.key'] = 'upload'
    poller.start
    wait_for_next_sync

    logger.should have_entry(:error, failure)

    client['test.key'] = 'test value'
    wait_for_next_sync

    cache['test.key'].should be_nil
  end

  it "logs an error if the background thread can't start" do
    Thread.stubs(:new => nil)
    logger = FakeLogger.new

    build_poller(:logger => logger).start

    logger.should have_entry(:error, "Couldn't start poller thread")
  end

  it "flushes the log when polling" do
    logger = FakeLogger.new
    logger.stubs(:flush)

    build_poller(:logger => logger).start

    wait_for_next_sync

    logger.should have_received(:flush).at_least_once
  end

  it "starts from the top-level constant" do
    poller = build_poller
    CopycopterClient.poller = poller
    poller.stubs(:start)

    CopycopterClient.start_poller

    poller.should have_received(:start)
  end
end


