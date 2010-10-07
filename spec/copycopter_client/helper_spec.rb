require 'spec_helper'
require 'copycopter_client/helper'

describe CopycopterClient::Helper do
  subject { Object.new }

  before do
    class << subject
      include CopycopterClient::Helper
      def warn(*args); end # these are annoying in test output
    end
    I18n.stubs(:translate)
  end

  Spec::Matchers.define :have_translated do |key, default|
    match do |ignored_subject|
      extend Mocha::API
      I18n.should have_received(:translate).with(key, default)
    end
  end

  it "translates keys on CopycopterClient.s" do
    CopycopterClient.s('test.key', 'default')
    should have_translated("test.key", 'default')
  end

  it "translates keys on CopycopterClient.copy_for" do
    CopycopterClient.copy_for('test.key', 'default')
    should have_translated("test.key", 'default')
  end

  it "should prepend current partial when key starts with . and inside a view" do
    template = stub(:path_without_format_and_extension => "controller/action")
    subject.stubs(:template => template)

    subject.s(".key")

    should have_translated("controller.action.key", nil)
  end

  it "should prepend controller and action when key starts with . and inside a controller" do
    subject.stubs(:controller_name => "controller", :action_name => "action")

    subject.s(".key")

    should have_translated("controller.action.key", nil)
  end

  describe "default assignment" do
    before do
      subject.stubs(:scope_key_by_partial => '.key')
    end

    it "should allow a hash with key default" do
      subject.s(@key, :default => "Default string")
      should have_translated('.key', "Default string")
    end

    it "should not allow a hash with stringed key default" do
      subject.s(@key, "default" => "Default string")
      should have_translated('.key', nil)
    end

    it "should not allow a hash with key other than default" do
      subject.s(@key, :junk => "Default string")
      should have_translated('.key', nil)
    end

    it "should allow a string" do
      subject.s(@key, "Default string")
      should have_translated('.key', "Default string")
    end
  end
end
