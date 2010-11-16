# Starts a Rails application server in a fork and waits for it to be responsive
class RailsServer
  HOST = 'localhost'.freeze

  class << self
    attr_accessor :instance
  end

  def self.start(port = nil)
    self.instance = new(port)
    self.instance.start
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
  end

  def start
    @pid = fork do
      unless ENV['DEBUG']
        output = StringIO.new("")
        $stdout = output
        $stderr = output
      end
      require 'config/environment'
      if Rails::VERSION::MAJOR == 3
        rails = Rails.application
      else
        rails = ActionController::Dispatcher.new
      end
      app = Identify.new(rails)
      Rack::Handler::Thin.run(app, :Port => @port, :AccessLog => [])
    end
    wait_until_responsive
  end

  def stop
    if @pid
      Process.kill('INT', @pid)
      Process.wait(@pid)
      @pid = nil
    end
  end

  def get(path)
    Net::HTTP.get(URI.parse("http://#{HOST}:#{@port}").merge(path))
  end

  def wait_until_responsive
    20.times do
      if responsive?
        return true
      else
        sleep(0.5)
      end
    end
    raise "Couldn't connect to Rails application server at #{HOST}:#{@port}"
  end

  def responsive?
    response = Net::HTTP.start(HOST, @port) { |http| http.get('/__identify__') }
    response.is_a?(Net::HTTPSuccess)
  rescue Errno::ECONNREFUSED, Errno::EBADF
    return false
  end

  # From Capybara::Server

  class Identify
    def initialize(app)
      @app = app
    end

    def call(env)
      if env["PATH_INFO"] == "/__identify__"
        [200, {}, 'OK']
      else
        @app.call(env)
      end
    end
  end
end
