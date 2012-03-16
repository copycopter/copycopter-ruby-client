class FakeClient
  def initialize
    @data = {}
    @uploaded = {}
    @uploads = 0
    @downloads = 0
  end

  attr_reader :uploaded, :uploads, :downloads
  attr_accessor :delay, :error

  def []=(key, value)
    @data[key] = value
  end

  def download
    wait_for_delay
    raise_error_if_present
    @downloads += 1
    yield @data.dup
    nil
  end

  def upload(data)
    wait_for_delay
    raise_error_if_present
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
    if delay
      sleep delay
    end
  end

  def raise_error_if_present
    if error
      raise error
    end
  end
end

