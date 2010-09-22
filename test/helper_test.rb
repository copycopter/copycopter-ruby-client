require File.dirname(__FILE__) + '/helper'

class HelperTest < Test::Unit::TestCase

  include CopycopterClient::Helper

  should "define a copy_for method" do
    assert respond_to?(:copy_for)
  end

  should "define a s method" do
    assert respond_to?(:s)
  end

  should "prepend current partial when key starts with . and inside a view" do
    template = stub(:path_without_format_and_extension => "controller/action")
    stubs(:template => template)
    CopycopterClient.stubs(:copy_for)

    s(".key")

    assert_received(CopycopterClient, :copy_for) do |expect|
      expect.with("controller.action.key", nil)
    end
  end

  should "prepend controller and action when key starts with . and inside a controller" do
    stubs(:controller_name => "controller", :action_name => "action")
    CopycopterClient.stubs(:copy_for)

    s(".key")

    assert_received(CopycopterClient, :copy_for) do |expect|
      expect.with("controller.action.key", nil)
    end
  end

  def expect_copy_for_with_default(default)
    assert_received(CopycopterClient, :copy_for) do |expect|
      expect.with(@key, default)
    end
  end

  context "default assignment" do
    setup do
      @key = ".key"
      stubs(:scope_key_by_partial => @key)
      CopycopterClient.stubs(:copy_for)
    end

    should "allow a hash with key default" do
      s(@key, :default => "Default string")
      expect_copy_for_with_default("Default string")
    end

    should "not allow a hash with stringed key default" do
      s(@key, "default" => "Default string")
      expect_copy_for_with_default(nil)
    end

    should "not allow a hash with key other than default" do
      s(@key, :junk => "Default string")
      expect_copy_for_with_default(nil)
    end

    should "allow a string" do
      s(@key, "Default string")
      expect_copy_for_with_default("Default string")
    end
  end
end
