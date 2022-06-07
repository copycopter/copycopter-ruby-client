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
        content_length = body.bytesize.to_s
        headers['Content-Length'] = content_length
        # maintains compatibility with other middlewares
        if defined?(ActionDispatch::Response::RackBody) && ActionDispatch::Response::RackBody === response
          ActionDispatch::Response.new(status, headers, [body]).to_a
        else
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

    def append_css(html)
      append_to_html_body(html, css_tag)
    end

    def append_js(html)
      json =
        if CopyTunerClient::TranslationLog.initialized?
          CopyTunerClient::TranslationLog.translations.to_json
        else
          '{}'
        end

      append_to_html_body(html, helpers.javascript_tag(<<~SCRIPT))
        window.CopyTuner = {
          url: '#{CopyTunerClient.configuration.project_url}',
          data: #{json},
        }
      SCRIPT
      append_to_html_body(html, helpers.javascript_include_tag(:main, type: 'module'))
    end

    def css_tag
      helpers.stylesheet_link_tag :style, media: :screen
    end

    def append_to_html_body(html, content)
      content = content.html_safe if content.respond_to?(:html_safe)
      return html unless html.include?('</body>')

      position = html.rindex('</body>')
      html.insert(position, content + "\n")
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
