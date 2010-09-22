require File.dirname(__FILE__) + '/helper'

class LoggerTest < Test::Unit::TestCase

  def stub_verbose_log
    CopycopterClient.stubs(:write_verbose_log)
  end

  def assert_logged(expected)
    assert_received(CopycopterClient, :write_verbose_log) do |expect|
      expect.with {|actual| actual =~ expected }
    end
  end

  def assert_not_logged(expected)
    assert_received(CopycopterClient, :write_verbose_log) do |expect|
      expect.with {|actual| actual =~ expected }.never
    end
  end

  def configure
    CopycopterClient.configure { |config| }
  end

  should "report that client is ready when configured" do
    stub_verbose_log
    configure
    assert_logged /Client (.*) ready/
  end

  should "not report that client is ready when internally configured" do
    stub_verbose_log
    CopycopterClient.configure(true) { |config | }
    assert_not_logged /.*/
  end

end
