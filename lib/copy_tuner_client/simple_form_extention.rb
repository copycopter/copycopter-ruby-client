# -*- coding: utf-8 -*-
require 'copy_tuner_client/copyray'

begin
  require "simple_form"
rescue LoadError
end

if defined?(SimpleForm)
  module SimpleForm::Components::Labels
    protected
    def label_translation_with_copyray_comment
      source = label_translation_without_copyray_comment
      # どこのキーかは特定しにくい
      CopyTunerClient::Copyray.augment_template(source, attribute_name)
    end
    alias_method_chain :label_translation, :copyray_comment
  end
end
