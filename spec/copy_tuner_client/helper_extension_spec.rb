require 'spec_helper'
require 'copy_tuner_client/helper_extension'
require 'copy_tuner_client/copyray'

describe CopyTunerClient::HelperExtension do
  # rails <= 6.0.x
  module HashArgumentHelper
    def translate(key, options = {})
      "Hello, #{options[:name]}"
    end
  end

  # rails >= 6.1.x
  module KeywordArgumentsHelper
    def translate(key, **options)
      "Hello, #{options[:name]}"
    end
  end

  class HashArgumentView
    include HashArgumentHelper
  end

  class KeywordArgumentsView
    include KeywordArgumentsHelper
  end

  CopyTunerClient::HelperExtension.hook_translation_helper(HashArgumentHelper, middleware_enabled: true)
  CopyTunerClient::HelperExtension.hook_translation_helper(KeywordArgumentsHelper, middleware_enabled: true)

  it 'works with hash argument method' do
    view = HashArgumentView.new
    expect(view.translate('some.key', name: 'World')).to eq '<!--COPYRAY some.key-->Hello, World'
  end

  it 'works with keyword argument method' do
    view = KeywordArgumentsView.new
    expect(view.translate('some.key', name: 'World')).to eq '<!--COPYRAY some.key-->Hello, World'
  end
end
