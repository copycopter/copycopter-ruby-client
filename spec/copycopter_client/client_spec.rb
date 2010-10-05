require 'spec_helper'

describe CopycopterClient do
  def build_client(config = {})
    default_config = CopycopterClient::Configuration.new.to_hash
    CopycopterClient::Client.new(default_config.update(config))
  end

  def add_project
    api_key = 'xyz123'
    FakeCopycopterApp.add_project(api_key)
  end

  it "should default timeout to 2 seconds"
  it "should allow override of timeout"
  it "should connect to the right port for ssl"
  it "should connect to the right port for non-ssl"
  it "should use ssl if secure"
  it "should not use ssl if not secure"

  it "downloads published blurbs for an existing project" do
    project = add_project
    project.draft['key.one'] = "unexpected one"
    project.draft['key.three'] = "unexpected three"
    project.published['key.one'] = "expected one"
    project.published['key.two'] = "expected two"

    blurbs = build_client(:api_key => project.api_key, :public => true).download

    blurbs.should == {
      'key.one' => 'expected one',
      'key.two' => 'expected two'
    }
  end
end

