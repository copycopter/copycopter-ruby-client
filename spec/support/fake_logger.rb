class FakeLogger
  def initialize
    @entries = {
      :info  => [],
      :debug => [],
      :warn  => [],
      :error => [],
      :fatal => [],
    }
  end

  def info(message = nil, &block)
    log(:info, message, &block)
  end

  def debug(message = nil, &block)
    log(:debug, message, &block)
  end

  def warn(message = nil, &block)
    log(:warn, message, &block)
  end

  def error(message = nil, &block)
    log(:error, message, &block)
  end

  def fatal(message = nil, &block)
    log(:fatal, message, &block)
  end

  def log(severity, message = nil, &block)
    message ||= block.call
    @entries[severity] << message
  end

  def has_entry?(level, expected_entry)
    @entries[level].any? { |actual_entry| actual_entry.include?(expected_entry) }
  end

  attr_reader :entries
end

RSpec::Matchers.define :have_entry do |severity, entry|
  match do |logger|
    @logger = logger
    logger.has_entry?(severity, entry)
  end

  failure_message_for_should do
    "Expected #{severity}(#{entry.inspect}); got entries:\n\n#{entries}"
  end

  failure_message_for_should_not do
    "Unexpected #{severity}(#{entry.inspect}); got entries:\n\n#{entries}"
  end

  def entries
    lines = @logger.entries.inject([]) do |result, (severity, entries)|
      if entries.empty?
        result
      else
        result << "#{severity}:\n#{entries.join("\n")}"
      end
    end
    lines.join("\n\n")
  end
end
