require 'rack'
require 'rack/request'
require 'rack/response'

# ref) NewRelic gem https://github.com/newrelic/rpm/blob/master/lib/new_relic/rack/developer_mode.rb

module CopyTunerClient
  # Rack middleware that synchronizes with CopyTuner during each request.
  #
  # This is injected into the Rails middleware stack in development environments.
  class RequestSync
    VIEW_PATH = File.expand_path('../../../ui/views/', __FILE__)

    # @param app [Rack] the upstream app into whose responses to inject the editor
    # @param options [Hash]
    # @option options [Cache] :cache agent that should be flushed after each request
    def initialize(app, options)
      @app = app
      @cache = options[:cache]
      @interval = options[:interval]
      @ignore_regex = options[:ignore_regex]
      @last_synced = options[:last_synced]
    end

    attr_accessor :last_synced

    # Invokes the upstream Rack application and flushes the cache after each
    # request.
    def call(env)
      if /^\/copytuner/ =~ ::Rack::Request.new(env).path_info
        dup._call(env)
      else
        @cache.download unless cancel_sync?(env)
        response = @app.call(env)
        @cache.flush    unless cancel_sync?(env)
        update_last_synced unless in_interval?
        response
      end
    end

    protected

    def _call(env)
      @req = ::Rack::Request.new(env)

      case @req.path_info
      when /^\/copytuner\/?$/
        index
      when /sync/
        sync
      else
        @app.call(env)
      end
    end

    private

    def index
      @next_sync_at = next_sync_at
      render :index
    end

    def sync
      @cache.sync
      ::Rack::Response.new{|r| r.redirect('/copytuner/')}.finish
    end

    def render(view, layout=true)
      add_rack_array = true
      if view.is_a? Hash
        layout = false
        if view[:object]
          object = view[:object]
        end

        if view[:collection]
          return view[:collection].map do |object|
            render({:partial => view[:partial], :object => object})
          end.join(' ')
        end

        if view[:partial]
          add_rack_array = false
          view = "_#{view[:partial]}"
        end
      end
      binding = Proc.new {}.binding
      if layout
        body = render_with_layout(view) do
          render_without_layout(view, binding)
        end
      else
        body = render_without_layout(view, binding)
      end
      if add_rack_array
        ::Rack::Response.new(body).finish
      else
        body
      end
    end

    # You have to call this with a block - the contents returned from
    # that block are interpolated into the layout
    def render_with_layout(view)
      body = ERB.new(File.read(File.join(VIEW_PATH, 'layouts/copytuner_default.html.erb')))
      body.result(Proc.new {}.binding)
    end

    # you have to pass a binding to this (a proc) so that ERB can have
    # access to helper functions and local variables
    def render_without_layout(view, binding)
      ERB.new(File.read(File.join(VIEW_PATH, 'copytuner', view.to_s + '.html.erb')), nil, nil, 'frobnitz').result(binding)
    end

    def cancel_sync?(env)
      asset_request?(env) or ignore_regex_request?(env) or in_interval?
    end

    def ignore_regex_request?(env)
      env['PATH_INFO'] =~ @ignore_regex
    end

    def asset_request?(env)
      env['PATH_INFO'] =~ /^\/assets/
    end

    def in_interval?
      return false if @last_synced.nil?
      return false if @interval <= 0
      next_sync_at > Time.now.utc
    end

    def next_sync_at
      @last_synced + @interval if @last_synced and @interval
    end

    def update_last_synced
      @last_synced = Time.now.utc
    end
  end
end
