class FakeResqueJob
  def initialize(&action)
    @action = action || lambda {}
  end

  def fork_and_perform
    fork do
      perform
      exit!
    end
    Process.wait
  end

  def perform
    @action.call
    true
  end
end
