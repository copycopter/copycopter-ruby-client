require 'spec_helper'

describe CopycopterClient::Sync do
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
end

