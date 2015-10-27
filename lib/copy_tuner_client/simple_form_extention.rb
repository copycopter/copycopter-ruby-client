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

      if object.class.respond_to?(:lookup_ancestors)
        attributes_scope = "#{object.class.i18n_scope}.attributes"
        defaults = object.class.lookup_ancestors.map do |klass|
          "#{attributes_scope}.#{klass.model_name.i18n_key}.#{reflection_or_attribute_name}"
        end
        CopyTunerClient::Copyray.augment_template(source, defaults.shift).html_safe
      else
        source
      end
    end
    if CopyTunerClient.configuration.enable_middleware?
      alias_method_chain :label_translation, :copyray_comment
    end
  end
end
