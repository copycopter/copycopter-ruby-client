module CopycopterClient
  # Rack middleware that synchronizes with Copycopter during each request.
  #
  # This is injected into the Rails middleware stack in development environments.
  class RequestSync
    # @param app [Rack] the upstream app into whose responses to inject the editor
    # @param options [Hash]
    # @option options [Cache] :cache agent that should be flushed after each request
    def initialize(app, options)
      @app  = app
      @cache = options[:cache]
    end

    # Invokes the upstream Rack application and flushes the cache after each
    # request.
    def call(env)
      @cache.download
      response = @app.call(env)
      @cache.flush
      response
    end
  end
end
