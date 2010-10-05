require 'spec_helper'

describe CopycopterClient::Sync do
  let(:data) { {} }
  let(:client) { stub('client', :download => data) }
  let(:config) { CopycopterClient::Configuration.new }

  subject { CopycopterClient::Sync.new(client, config.to_hash) }

  it "downloads blurbs when starting" do
    subject.start
    client.should have_received(:download)
  end

  it "provides access to downloaded data" do
    data['en.test.key'] = 'expected'
    data['en.test.other_key'] = 'expected'

    subject.start

    subject['en.test.key'].should == 'expected'
    subject.keys.should =~ %w(en.test.key en.test.other_key)
  end
end

