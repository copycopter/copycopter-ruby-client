require 'spec_helper'

describe CopycopterClient::Sync do
  class FakeClient
    def initialize
      @data = {}
      @uploaded = {}
      @uploads = 0
    end

    attr_reader :uploaded

    def []=(key, value)
      @data[key] = value
    end

    def download
      @data.dup
    end

    def upload(data)
      @uploaded.update(data)
      @uploads += 1
    end

    def uploaded?
      @uploads > 0
    end
  end

  let(:client) { FakeClient.new }

  def build_sync(config = {})
    default_config = CopycopterClient::Configuration.new.to_hash
    sync = CopycopterClient::Sync.new(client, default_config.update(config))
    @syncs << sync
    sync
  end

  before do
    @syncs = []
  end

  after { @syncs.each { |sync| sync.stop } }

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

  it "syncronizes changes downloads threads"
  it "syncronizes changes uploads threads"
end

