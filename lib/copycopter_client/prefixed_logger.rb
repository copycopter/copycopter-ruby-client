module CopycopterClient
  # Wraps a standard Ruby Logger and applies a prefix to all messages.
  # See +Logger+ in the standard Ruby documentation for more information about
  # loggers.
  class PrefixedLogger
    attr_reader :prefix, :original_logger

    # @param prefix [String] prefix to be applied to messages
    # @param logger [Logger] the original logger to which prefixes are applied
    def initialize(prefix, logger)
      @prefix          = prefix
      @original_logger = logger
    end

    # Logs an info message
    def info(message = nil, &block)
      log(:info, message, &block)
    end

    # Logs a debug message
    def debug(message = nil, &block)
      log(:debug, message, &block)
    end

    # Logs a warning message
    def warn(message = nil, &block)
      log(:warn, message, &block)
    end

    # Logs an error message
    def error(message = nil, &block)
      log(:error, message, &block)
    end

    # Logs a fatal message
    def fatal(message = nil, &block)
      log(:fatal, message, &block)
    end

    private

    def log(severity, message, &block)
      prefixed_message = "#{prefix} #{thread_info} #{message}"
      original_logger.send(severity, prefixed_message, &block)
    end

    def thread_info
      "[P:#{Process.pid}] [T:#{Thread.current.object_id}]"
    end
  end
end
