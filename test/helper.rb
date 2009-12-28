require 'test/unit'
require 'rubygems'

gem 'jferris-mocha', '0.9.5.0.1241126838'

require 'shoulda'
require 'mocha'

require 'action_controller'
require 'action_controller/test_process'
require 'active_record'
require 'active_record/base'
require 'active_support'
require 'nokogiri'
require 'webmock/test_unit'

include WebMock
WebMock.disable_net_connect!

require File.join(File.dirname(__FILE__), "..", "lib", "skywriter_client")

begin require 'redgreen'; rescue LoadError; end

class Test::Unit::TestCase
  # Borrowed from ActiveSupport 2.3.2
  def assert_difference(expression, difference = 1, message = nil, &block)
    b = block.send(:binding)
    exps = Array.wrap(expression)
    before = exps.map { |e| eval(e, b) }

    yield

    exps.each_with_index do |e, i|
      error = "#{e.inspect} didn't change by #{difference}"
      error = "#{message}.\n#{error}" if message
      assert_equal(before[i] + difference, eval(e, b), error)
    end
  end

  def assert_no_difference(expression, message = nil, &block)
    assert_difference expression, 0, message, &block
  end

  def reset_config
    SkywriterClient.configuration = nil
    SkywriterClient.configure do |config|
      config.api_key = 'abc123'
    end
  end
end

module DefinesConstants
  def setup
    @defined_constants = []
  end

  def teardown
    @defined_constants.each do |constant|
      Object.__send__(:remove_const, constant)
    end
  end

  def define_constant(name, value)
    Object.const_set(name, value)
    @defined_constants << name
  end
end

class FakeLogger
  def info(*args);  end
  def debug(*args); end
  def warn(*args);  end
  def error(*args); end
  def fatal(*args); end
end

RAILS_DEFAULT_LOGGER = FakeLogger.new

