require 'spec_helper'

describe CopycopterClient::PrefixedLogger do
  let(:output_logger) { FakeLogger.new }
  let(:prefix) { "** NOTICE:" }
  let(:thread_info) { "[P:#{Process.pid}] [T:#{Thread.current.object_id}]" }
  subject { CopycopterClient::PrefixedLogger.new(prefix, output_logger) }

  it "provides the prefix" do
    subject.prefix.should == prefix
  end

  it "provides the logger" do
    subject.original_logger.should == output_logger
  end

  [:debug, :info, :warn, :error, :fatal].each do |level|
    it "prefixes #{level} log messages" do
      message = 'hello'
      subject.send(level, message)

      output_logger.should have_entry(level, "#{prefix} #{thread_info} #{message}")
    end
  end

  it "calls flush for a logger that responds to flush" do
    output_logger.stubs(:flush)

    subject.flush

    output_logger.should have_received(:flush)
  end

  it "doesn't call flush for a logger that doesn't respond to flush" do
    lambda { subject.flush }.should_not raise_error
  end
end
