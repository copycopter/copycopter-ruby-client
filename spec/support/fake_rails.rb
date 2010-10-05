module Rails
  class FakeLogger
    def info(*args);  end
    def debug(*args); end
    def warn(*args);  end
    def error(*args); end
    def fatal(*args); end
  end

  class << self
    attr_accessor :cache
    attr_accessor :logger
  end

  self.logger = FakeLogger.new
end

