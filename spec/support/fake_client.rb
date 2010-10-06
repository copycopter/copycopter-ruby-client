class FakeClient
  def initialize
    @data = {}
    @uploaded = {}
    @uploads = 0
    @downloads = 0
  end

  attr_reader :uploaded, :uploads, :downloads

  def []=(key, value)
    @data[key] = value
  end

  def download
    @downloads += 1
    @data.dup
  end

  def upload(data)
    @uploaded.update(data)
    @uploads += 1
  end

  def uploaded?
    @uploads > 0
  end

  def downloaded?
    @downloads > 0
  end
end

