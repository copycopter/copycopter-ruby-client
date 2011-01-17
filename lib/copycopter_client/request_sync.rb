module CopycopterClient
  # Rack middleware that synchronizes with Copycopter after each request.
  #
  # This is injected into the Rails middleware stack in development environments.
  class RequestSync
    # @param app [Rack] the upstream app into whose responses to inject the editor
    # @param options [Hash]
    # @option options [Sync] :sync agent that should be flushed after each request
    def initialize(app, options)
      @app  = app
      @sync = options[:sync]
    end

    # Invokes the upstream Rack application and flushes the sync after each
    # request.
    def call(env)
      response = @app.call(env)
      @sync.flush
      response
    end
  end
end
