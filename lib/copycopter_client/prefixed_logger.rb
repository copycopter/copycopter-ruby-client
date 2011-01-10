module CopycopterClient
  class PrefixedLogger
    attr_reader :prefix, :original_logger

    def initialize(prefix, logger)
      @prefix          = prefix
      @original_logger = logger
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

    def flush
      original_logger.flush if original_logger.respond_to?(:flush)
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
