class RailsServer
  class << self
    attr_accessor :instance
  end

  def self.start(port = nil)
    self.instance = new(port)
  end

  def self.stop
    self.instance.stop if instance
    self.instance = nil
  end

  def self.get(path)
    self.instance.get(path)
  end

  def initialize(port)
    @port = (port || 3001).to_i
    @output = StringIO.new("")
    @pid = fork do
      $stdout = self.output
      $stderr = self.output
      require 'config/environment'
      app = ActionController::Dispatcher.new
      Rack::Handler::Thin.run(app, :Port => @port, :AccessLog => [])
    end
    sleep(5) # wait for app server to start
  end

  attr_accessor :output

  def stop
    Process.kill('INT', @pid)
    Process.wait(@pid)
  end

  def get(path)
    Net::HTTP.get(URI.parse("http://localhost:#{@port}").merge(path))
  end
end
