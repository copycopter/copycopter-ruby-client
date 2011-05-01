class FakeResqueJob
  def initialize(&action)
    @action = action
  end

  def perform
    @action.call
    true
  end
end
