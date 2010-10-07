module Rails
  class << self
    attr_accessor :cache
    attr_accessor :logger
  end

  self.logger = FakeLogger.new
end

