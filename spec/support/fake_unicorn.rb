class FakeUnicornServer
  def become_master
    $0 = "unicorn"
  end

  def spawn
    worker_loop(nil)
  end

  def worker_loop(worker)
  end
end

