# cf) xray-rails : xray/middleware.rb

module CopyTunerClient
  class CopyrayMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      CopyTunerClient::TranslationLog.clear
      status, headers, response = @app.call(env)
      if html_headers?(status, headers) && body = response_body(response)
        body = append_css(body)
        body = append_js(body)
        body = append_translation_logs(body)
        body = inject_copy_tuner_bar(body)
        content_length = body.bytesize.to_s
        if ActionDispatch::Response === response
          response.body = [body]
          response.headers['Content-Length'] = content_length
          response.to_a
        else
          headers['Content-Length'] = content_length
          [status, headers, [body]]
        end
      else
        [status, headers, response]
      end
    end

    private

    def helpers
      ActionController::Base.helpers
    end

    def append_translation_logs(html)
      if CopyTunerClient::TranslationLog.initialized?
        json = CopyTunerClient::TranslationLog.translations.to_json
        # Use block to avoid back reference \?
        html.sub('</body>') { "<div id='copy-tuner-data' data-copy-tuner-translation-log='#{ERB::Util.html_escape json}' data-copy-tuner-url='#{CopyTunerClient.configuration.project_url}'></div></body>" }
      else
        html
      end
    end

    def inject_copy_tuner_bar(html)
      html.sub(/<body[^>]*>/) { "#{Regexp.last_match}\n#{render_copy_tuner_bar}" }
    end

    def render_copy_tuner_bar
      if ApplicationController.respond_to?(:render)
        # Rails 5
        ApplicationController.render(:partial => "/copy_tuner_bar").html_safe
      else
        # Rails <= 4.2
        ac = ActionController::Base.new
        ac.render_to_string(:partial => '/copy_tuner_bar').html_safe
      end
    end

    def append_css(html)
      html.sub(/<body[^>]*>/) { "#{Regexp.last_match}\n#{css_tag}" }
    end

    def append_js(html)
      html.sub(%r{</body>}) do
       "#{helpers.javascript_include_tag(:copyray)}\n#{Regexp.last_match}"
      end
    end

    def css_tag
      helpers.stylesheet_link_tag :copyray
    end

    def file?(headers)
      headers["Content-Transfer-Encoding"] == "binary"
    end

    def html_headers?(status, headers)
      status == 200 &&
      headers['Content-Type'] &&
      headers['Content-Type'].include?('text/html') &&
      !file?(headers)
    end

    def response_body(response)
      body = ''
      response.each { |s| body << s.to_s }
      body
    end
  end
end
