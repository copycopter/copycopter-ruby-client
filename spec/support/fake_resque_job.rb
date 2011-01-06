class FakeResqueJob
  attr_accessor :sync
  def initialize(hash)
    @key = hash[:key]
    @value = hash[:value]
  end
  def perform
    sync[@key] = @value
    true
  end
end
