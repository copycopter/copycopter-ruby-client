require 'spec_helper'

describe CopycopterClient::ProcessGuard do
  include DefinesConstants

  before do
    @original_process_name = $0
  end

  after do
    $0 = @original_process_name
  end

  let(:cache) { stub('cache', :flush => nil) }
  let(:poller) { stub('poller', :start => nil) }

  def build_process_guard(options = {})
    options[:logger] ||= FakeLogger.new
    options[:cache]  ||= cache
    CopycopterClient::ProcessGuard.new(options[:cache], poller, options)
  end

  it "starts polling from a worker process" do
    process_guard = build_process_guard

    process_guard.start

    poller.should have_received(:start)
  end

  it "registers passenger hooks from the passenger master" do
    logger = FakeLogger.new
    passenger = define_constant('PhusionPassenger', FakePassenger.new)
    passenger.become_master

    process_guard = build_process_guard(:logger => logger)
    process_guard.start

    logger.should have_entry(:info, "Registered Phusion Passenger fork hook")
    poller.should have_received(:start).never
  end

  it "starts polling from a passenger worker" do
    logger = FakeLogger.new
    passenger = define_constant('PhusionPassenger', FakePassenger.new)
    passenger.become_master
    process_guard = build_process_guard(:logger => logger)

    process_guard.start
    passenger.spawn

    poller.should have_received(:start)
  end

  it "registers unicorn hooks from the unicorn master" do
    logger = FakeLogger.new
    define_constant('Unicorn', Module.new)
    http_server = Class.new(FakeUnicornServer)
    unicorn = define_constant('Unicorn::HttpServer', http_server).new
    unicorn.become_master

    process_guard = build_process_guard(:logger => logger)
    process_guard.start

    logger.should have_entry(:info, "Registered Unicorn fork hook")
    poller.should have_received(:start).never
  end

  it "starts polling from a unicorn worker" do
    logger = FakeLogger.new
    define_constant('Unicorn', Module.new)
    http_server = Class.new(FakeUnicornServer)
    unicorn = define_constant('Unicorn::HttpServer', http_server).new
    unicorn.become_master
    process_guard = build_process_guard(:logger => logger)

    process_guard.start
    unicorn.spawn

    poller.should have_received(:start)
  end

  it "flushes when the process terminates" do
    cache = WritingCache.new
    pid = fork do
      process_guard = build_process_guard(:cache => cache)
      process_guard.start
      exit
    end
    Process.wait

    cache.should be_written
  end

  it "flushes after running a resque job" do
    logger = FakeLogger.new
    cache = WritingCache.new
    define_constant('Resque', Module.new)
    job_class = define_constant('Resque::Job', FakeResqueJob)
    job = job_class.new
    process_guard = build_process_guard(:cache => cache, :logger => logger)

    process_guard.start
    job.fork_and_perform

    cache.should be_written
    logger.should have_entry(:info, "Registered Resque after_perform hook")
  end

  it "doesn't fail if only Resque is defined and not Resque::Job" do
    logger = FakeLogger.new
    cache = WritingCache.new
    define_constant('Resque', Module.new)
    process_guard = build_process_guard(:cache => cache, :logger => logger)

    process_guard.start
  end
end
