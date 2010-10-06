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
    project.update({
      'draft' => {
        'key.one'   => "unexpected one",
        'key.three' => "unexpected three"
      },
      'published' => {
        'key.one' => "expected one",
        'key.two' => "expected two"
      }
    })

    blurbs = build_client(:api_key => project.api_key, :public => true).download

    blurbs.should == {
      'key.one' => 'expected one',
      'key.two' => 'expected two'
    }
  end

  it "downloads draft blurbs for an existing project" do
    project = add_project
    project.update({
      'draft' => {
        'key.one' => "expected one",
        'key.two' => "expected two"
      },
      'published' => {
        'key.one'   => "unexpected one",
        'key.three' => "unexpected three"
      }
    })

    blurbs = build_client(:api_key => project.api_key, :public => false).download

    blurbs.should == {
      'key.one' => 'expected one',
      'key.two' => 'expected two'
    }
  end

  it "uploads defaults for missing blurbs in an existing project" do
    project = add_project

    blurbs = {
      'key.one' => 'expected one',
      'key.two' => 'expected two'
    }

    client = build_client(:api_key => project.api_key, :public => true)
    client.upload(blurbs)

    project.reload.draft.should == blurbs
  end
end

