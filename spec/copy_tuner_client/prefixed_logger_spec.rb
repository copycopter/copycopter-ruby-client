require 'spec_helper'

describe CopyTunerClient::PrefixedLogger do
  let(:output_logger) { FakeLogger.new }
  let(:prefix) { "** NOTICE:" }
  let(:thread_info) { "[P:#{Process.pid}] [T:#{Thread.current.object_id}]" }
  subject { CopyTunerClient::PrefixedLogger.new(prefix, output_logger) }

  it "provides the prefix" do
    expect(subject.prefix).to eq(prefix)
  end

  it "provides the logger" do
    expect(subject.original_logger).to eq(output_logger)
  end

  [:debug, :info, :warn, :error, :fatal].each do |level|
    it "prefixes #{level} log messages" do
      message = 'hello'
      subject.send(level, message)

      expect(output_logger).to have_entry(level, "#{prefix} #{thread_info} #{message}")
    end
  end

  it "calls flush for a logger that responds to flush" do
    expect(output_logger).to receive(:flush)

    subject.flush
  end

  it "doesn't call flush for a logger that doesn't respond to flush" do
    expect { subject.flush }.not_to raise_error
  end
end
