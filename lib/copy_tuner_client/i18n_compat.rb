require 'nokogiri'

module CopyTunerClient
  module I18nCompat
    def select_html_incompatible_blurbs(blurbs)
      non_html_key_blurbs = blurbs.reject { |key| key.ends_with?('.html') || key.ends_with?('_html') }
      html_blurbs = non_html_key_blurbs.select do |key, content|
        Nokogiri::HTML.fragment(content).children.any? { |node| node.name != 'text' }
      end
    end

    module_function :select_html_incompatible_blurbs
  end
end
