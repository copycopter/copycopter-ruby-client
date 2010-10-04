require 'spec_helper'

describe "logging" do
  def stub_verbose_log
    CopycopterClient.stubs(:write_verbose_log)
  end

  Spec::Matchers.define :have_logged do |expected|
    match do |ignore_subject|
      extend Mocha::API
      match = have_received(:write_verbose_log).with {|actual| actual =~ expected  }
      match = match.never if @never
      CopycopterClient.should match
    end

    chain :never do
      @never = true
    end
  end

  def configure
    CopycopterClient.configure { |config| }
  end

  it "should report that client is ready when configured" do
    stub_verbose_log
    configure
    should have_logged(/Client (.*) ready/)
  end

  it "should not report that client is ready when internally configured" do
    stub_verbose_log
    CopycopterClient.configure(true) { |config | }
    should have_logged(/.*/).never
  end
end
