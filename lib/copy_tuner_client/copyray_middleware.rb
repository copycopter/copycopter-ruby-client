# cf) xray-rails : xray/middleware.rb

module CopyTunerClient
  class CopyrayMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      if html_headers?(status, headers) && body = response_body(response)
        body = append_css!(body)
        body = append_js!(body)
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

    def append_css!(html)
      html.sub(/<body[^>]*>/) { "#{$~}\n#{css_tag}" }
    end

    def append_js!(html)
      regexp = if ::Rails.application.config.assets.debug
                 # Matches:
                 #   <script src="/assets/jquery.js"></script>
                 #   <script src="/assets/jquery-min.js"></script>
                 #   <script src="/assets/jquery.min.1.9.1.js"></script>
                 /<script[^>]+\/jquery([-.]{1}[\d\.]+)?([-.]{1}min)?\.js[^>]+><\/script>/
               else
                 # Matches:
                 #   <script src="/application-xxxxxxx.js"></script>
                 /<script[^>]+\/application-[\w]+\.js[^>]+><\/script>/
               end
      html.sub(regexp) do
        "#{$~}\n" + helpers.javascript_include_tag(:copyray)
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
