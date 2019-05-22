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

      if !CopyTunerClient.configuration.disable_copyray_comment_injection && object.class.respond_to?(:lookup_ancestors)
        attributes_scope = "#{object.class.i18n_scope}.attributes"
        defaults = object.class.lookup_ancestors.map do |klass|
          "#{attributes_scope}.#{klass.model_name.i18n_key}.#{reflection_or_attribute_name}"
        end
        CopyTunerClient::Copyray.augment_template(source, defaults.shift)
      else
        source
      end
    end
    if CopyTunerClient.configuration.enable_middleware?
      alias_method :label_translation_without_copyray_comment, :label_translation
      alias_method :label_translation, :label_translation_with_copyray_comment
    end
  end
end
