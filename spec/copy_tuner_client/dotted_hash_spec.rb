require 'spec_helper'

describe CopyTunerClient::DottedHash do
  describe ".to_hash" do
    subject { CopyTunerClient::DottedHash.to_hash(dotted_hash) }

    context 'empty keys' do
      let(:dotted_hash) { {} }

      it { is_expected.to eq({}) }
    end

    context 'with single-level keys' do
      let(:dotted_hash) { { 'key' => 'test value', other_key: 'other value' } }

      it { is_expected.to eq({ 'key' => 'test value', 'other_key' => 'other value' }) }
    end

    context "with multi-level blurb keys" do
      let(:dotted_hash) do
        {
          'en.test.key' => 'en test value',
          'en.test.other_key' => 'en other test value',
          'fr.test.key' => 'fr test value',
        }
      end

      it do
        is_expected.to eq({
          'en' => {
            'test' => {
              'key' => 'en test value',
              'other_key' => 'en other test value',
            },
          },
          'fr' => {
            'test' => {
              'key' => 'fr test value',
            },
          },
        })
      end
    end

    context "with conflicting keys" do
      let(:dotted_hash) do
        {
          'en.test' => 'invalid value',
          'en.test.key' => 'en test value',
        }
      end

      it { is_expected.to eq({ 'en' => { 'test' => { 'key' => 'en test value' } } }) }
    end
  end

  describe ".invalid_keys" do
    subject { CopyTunerClient::DottedHash.invalid_keys(dotted_hash) }

    context 'valid keys' do
      let(:dotted_hash) do
        {
          'ja.hoge.test' => 'test',
          'ja.hoge.fuga' => 'test',
        }
      end

      it { is_expected.to eq({}) }
    end

    context 'invalid keys' do
      let(:dotted_hash) do
        {
          'ja.hoge.test' => 'test',
          'ja.hoge.test.hoge' => 'test',
          'ja.hoge.test.fuga' => 'test',
          'ja.fuga.test.hoge' => 'test',
          'ja.fuga.test' => 'test',
        }
      end

      it do
        is_expected.to eq({
          'ja.hoge.test' => %w[ja.hoge.test.hoge ja.hoge.test.fuga],
          'ja.fuga.test' => %w[ja.fuga.test.hoge],
        })
      end
    end
  end
end
