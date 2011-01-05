class FakeUnicornServer
  def become_master
    $0 = "unicorn master"
  end

  def spawn
    $0 = "PassengerFork"
    worker_loop(nil)
  end

  def worker_loop(worker)
  end
end

