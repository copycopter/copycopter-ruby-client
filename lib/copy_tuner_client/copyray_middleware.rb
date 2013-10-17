# cf) xray-rails : xray/middleware.rb

module CopyTunerClient
  class CopyrayMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, response = @app.call(env)
      if should_inject_xray?(status, headers, response)
        body = response.body
        # if Rails.application.config.assets.debug
          append_js!(body, 'jquery', :copyray)
        # end
        headers['Content-Length'] = body.bytesize.to_s
      end
      [status, headers, (body ? [body] : response)]
    end

    private

    # Appends the given `script_name` after the `after_script_name`.
    def append_js!(html, after_script_name, script_name)
      # Matches:
      #   <script src="/assets/jquery.js"></script>
      #   <script src="/assets/jquery-min.js"></script>
      #   <script src="/assets/jquery.min.1.9.1.js"></script>
      html.sub!(/<script[^>]+\/#{after_script_name}([-.]{1}[\d\.]+)?([-.]{1}min)?\.js[^>]+><\/script>/) do
        h = ActionController::Base.helpers
        "#{$~}\n" + h.javascript_include_tag(script_name)
      end
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
