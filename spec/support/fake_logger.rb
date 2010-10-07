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

  def has_entry?(level, entry)
    @entries[level].include?(entry)
  end

  attr_reader :entries
end

