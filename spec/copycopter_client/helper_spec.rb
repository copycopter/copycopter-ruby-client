require 'spec_helper'

describe CopycopterClient::Helper do
  include CopycopterClient::Helper

  subject { self }

  it "should define a copy_for method" do
    should respond_to(:copy_for)
  end

  it "should define a s method" do
    should respond_to(:s)
  end

  it "should prepend current partial when key starts with . and inside a view" do
    template = stub(:path_without_format_and_extension => "controller/action")
    stubs(:template => template)
    CopycopterClient.stubs(:copy_for)

    s(".key")

    CopycopterClient.should have_received(:copy_for).with("controller.action.key", nil)
  end

  it "should prepend controller and action when key starts with . and inside a controller" do
    stubs(:controller_name => "controller", :action_name => "action")
    CopycopterClient.stubs(:copy_for)

    s(".key")

    CopycopterClient.should have_received(:copy_for).with("controller.action.key", nil)
  end

  Spec::Matchers.define :request_copy_with_default do |default|
    match do |ignored_subject|
      extend Mocha::API
      CopycopterClient.should have_received(:copy_for).with(anything, default)
    end
  end

  describe "default assignment" do
    before do
      stubs(:scope_key_by_partial => '.key')
      CopycopterClient.stubs(:copy_for)
    end

    it "should allow a hash with key default" do
      s(@key, :default => "Default string")
      should request_copy_with_default("Default string")
    end

    it "should not allow a hash with stringed key default" do
      s(@key, "default" => "Default string")
      should request_copy_with_default(nil)
    end

    it "should not allow a hash with key other than default" do
      s(@key, :junk => "Default string")
      should request_copy_with_default(nil)
    end

    it "should allow a string" do
      s(@key, "Default string")
      should request_copy_with_default("Default string")
    end
  end
end
