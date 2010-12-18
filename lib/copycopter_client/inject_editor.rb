require 'copycopter_client/recording_i18n_backend'

module CopycopterClient
  # Rack middleware that injects a Copycopter editor into HTML responses
  class InjectEditor
    # @param app [Rack] the upstream app into whose responses to inject the editor
    # @param config [Hash]
    # @option config [String] :host host on which editor assets can be found
    def initialize(app, config = {})
      @app = app
      @host = config[:host]
    end

    # Invokes the upstream Rack application and injects the editor into any
    # successful HTML responses that contain a <body> tag
    def call(env)
      response = nil
      keys = record { response = @app.call(env) }
      status, headers, body =*response

      if status == 200 && headers['Content-Type'].include?('text/html')
        [status, headers, inject_into(body, keys)]
      else
        [status, headers, body]
      end
    end

    private

    attr_reader :host

    def inject_into(body_parts, keys)
      body = ""
      body_parts.each { |part| body << part }
      [body.sub("</body>", "#{editor_html_for(keys)}</body>")]
    end

    def editor_html_for(keys)
      keys_as_json = "[" + keys.map { |key| %{"#{key}"} }.join(",") + "]"
      %{<script type="text/javascript" href="#{editor_url}"></script>} +
        %{<script type="text/javascript">\n} +
        %{CopycopterEditor.editKeys(#{keys_as_json})\n} +
        %{</script>}
    end

    def editor_url
      "http://#{host}/javascripts/editor.js"
    end

    def keys_as_json
      ""
    end

    def record(&block)
      upstream_backend = I18n.backend
      begin
        recording_backend = RecordingI18nBackend.new(upstream_backend)
        I18n.backend = recording_backend
        recording_backend.record(&block)
      ensure
        I18n.backend = upstream_backend
      end
    end
  end
end
