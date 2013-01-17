module CopyTunerClient
  # Rack middleware that synchronizes with CopyTuner during each request.
  #
  # This is injected into the Rails middleware stack in development environments.
  class RequestSync
    # @param app [Rack] the upstream app into whose responses to inject the editor
    # @param options [Hash]
    # @option options [Cache] :cache agent that should be flushed after each request
    def initialize(app, options)
      @app  = app
      @cache = options[:cache]
      @interval = options[:interval] || 1.minutes
      @last_synced = Time.now.utc
    end

    # Invokes the upstream Rack application and flushes the cache after each
    # request.
    def call(env)
      @cache.download unless asset_request?(env) or in_interval?
      response = @app.call(env)
      @cache.flush    unless asset_request?(env) or in_interval?
      update_last_synced unless in_interval?
      response
    end

    private
    def asset_request?(env)
      env['PATH_INFO'] =~ /^\/assets/
    end

    def in_interval?
      @last_synced + @interval > Time.now.utc
    end

    def update_last_synced
      @last_synced = Time.now.utc
    end
  end
end
