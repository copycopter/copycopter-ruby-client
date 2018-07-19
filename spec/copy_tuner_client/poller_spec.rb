require 'spec_helper'

describe CopyTunerClient::Poller do
  POLLING_DELAY = 0.5

  let(:client) { FakeClient.new }
  let(:cache) { CopyTunerClient::Cache.new(client, :logger => FakeLogger.new) }

  def build_poller(config = {})
    config[:logger] ||= FakeLogger.new
    config[:polling_delay] = POLLING_DELAY
    default_config = CopyTunerClient::Configuration.new.to_hash
    poller = CopyTunerClient::Poller.new(cache, default_config.update(config))
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

    expect(cache['test.key']).to eq('value')
  end

  it "it doesn't poll before being started" do
    poller = build_poller
    client['test.key'] = 'value'

    wait_for_next_sync

    expect(cache['test.key']).to be_nil
  end

  it "stops polling when stopped" do
    poller = build_poller

    poller.start
    poller.stop

    client['test.key'] = 'value'
    wait_for_next_sync

    expect(cache['test.key']).to be_nil
  end

  it "stops polling with an invalid api key" do
    failure = "server is napping"
    logger = FakeLogger.new

    expect(cache).to receive(:download).and_raise(CopyTunerClient::InvalidApiKey.new(failure))
    poller = build_poller(:logger => logger)

    cache['upload.key'] = 'upload'
    poller.start
    wait_for_next_sync

    expect(logger).to have_entry(:error, failure)

    client['test.key'] = 'test value'
    wait_for_next_sync

    expect(cache['test.key']).to be_nil
  end

  it "logs an error if the background thread can't start" do
    expect(Thread).to receive(:new).and_return(nil)
    logger = FakeLogger.new

    build_poller(:logger => logger).start

    expect(logger).to have_entry(:error, "Couldn't start poller thread")
  end

  it "flushes the log when polling" do
    logger = FakeLogger.new
    expect(logger).to receive(:flush).at_least(:once)

    build_poller(:logger => logger).start

    wait_for_next_sync
  end
end
