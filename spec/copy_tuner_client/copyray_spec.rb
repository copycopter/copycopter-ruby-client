require 'spec_helper'
require 'copy_tuner_client/copyray'

describe CopyTunerClient::Copyray do
  describe '.augment_template' do
    subject { CopyTunerClient::Copyray.augment_template(source, key) }

    let(:key) { 'en.test.key' }

    shared_examples 'Not escaped' do
      it { is_expected.to be_html_safe }
      it { is_expected.to eq "<!--COPYRAY #{key}--><b>Hello</b>" }
    end

    context 'html_escape option is false' do
      before do
        CopyTunerClient.configure do |configuration|
          configuration.html_escape = false
          configuration.client = FakeClient.new
        end
      end

      context 'string not marked as html safe' do
        let(:source) { FakeHtmlSafeString.new('<b>Hello</b>') }

        it_behaves_like 'Not escaped'
      end

      context 'string marked as html safe' do
        let(:source) { FakeHtmlSafeString.new('<b>Hello</b>').html_safe }

        it_behaves_like 'Not escaped'
      end
    end

    context 'html_escape option is true' do
      before do
        CopyTunerClient.configure do |configuration|
          configuration.html_escape = true
          configuration.client = FakeClient.new
        end
      end

      context 'string not marked as html safe' do
        let(:source) { FakeHtmlSafeString.new('<b>Hello</b>') }

        it { is_expected.to be_html_safe }
        it { is_expected.to eq "<!--COPYRAY #{key}-->&lt;b&gt;Hello&lt;/b&gt;" }
      end

      context 'string marked as html safe' do
        let(:source) { FakeHtmlSafeString.new('<b>Hello</b>').html_safe }

        it_behaves_like 'Not escaped'
      end
    end
  end
end
