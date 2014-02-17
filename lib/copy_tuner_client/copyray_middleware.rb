# cf) xray-rails : xray/middleware.rb

module CopyTunerClient
  class CopyrayMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      if should_inject_xray?(status, headers, response)
        body = append_css!(response)
        body = append_js!(body)
        headers['Content-Length'] = body.bytesize.to_s
      end
      [status, headers, (body ? [body] : response)]
    end

    private

    def helpers
      ActionController::Base.helpers
    end

    def append_css!(response)
      response.body.sub(/<body[^>]*>/) { "#{$~}\n#{css_tag}" }
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

    def should_inject_xray?(status, headers, response)
      status == 200 &&
      !empty?(response) &&
      html_request?(headers, response) &&
      !file?(headers) &&
      !response.body.frozen?
    end

    def empty?(response)
      # response may be ["Not Found"], ["Move Permanently"], etc.
      (response.is_a?(Array) && response.size <= 1) ||
        !response.respond_to?(:body) || response.body.empty?
    end

    def file?(headers)
      headers["Content-Transfer-Encoding"] == "binary"
    end

    def html_request?(headers, response)
      headers['Content-Type'] && headers['Content-Type'].include?('text/html') && response.body.include?("<html")
    end
  end
end
