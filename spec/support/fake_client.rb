class FakeClient
  def initialize
    @data = {}
    @uploaded = {}
    @uploads = 0
    @downloads = 0
  end

  attr_reader :uploaded, :uploads, :downloads
  attr_accessor :delay

  def []=(key, value)
    @data[key] = value
  end

  def download
    wait_for_delay
    @downloads += 1
    yield @data.dup
    nil
  end

  def upload(data)
    wait_for_delay
    @uploaded.update(data)
    @uploads += 1
  end

  def uploaded?
    @uploads > 0
  end

  def downloaded?
    @downloads > 0
  end

  private

  def wait_for_delay
    sleep(delay) if delay
  end
end

