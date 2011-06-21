module CopycopterClient
  # Starts the poller from a worker process, or register hooks for a spawner
  # process (such as in Unicorn or Passenger). Also registers hooks for exiting
  # processes and completing background jobs. Applications using the client
  # will not need to interact with this class directly.
  class ProcessGuard
    # @param options [Hash]
    # @option options [Logger] :logger where errors should be logged
    def initialize(cache, poller, options)
      @cache  = cache
      @poller = poller
      @logger = options[:logger]
    end

    # Starts the poller or registers hooks
    def start
      if spawner?
        register_spawn_hooks
      else
        register_exit_hooks
        register_job_hooks
        start_polling
      end
    end

    private

    def start_polling
      @poller.start
    end

    def spawner?
      passenger_spawner? || unicorn_spawner?
    end

    def passenger_spawner?
      $0.include?("ApplicationSpawner")
    end

    def unicorn_spawner?
      $0.include?("unicorn") && !caller.any? { |line| line.include?("worker_loop") }
    end

    def register_spawn_hooks
      if defined?(PhusionPassenger)
        register_passenger_hook
      elsif defined?(Unicorn::HttpServer)
        register_unicorn_hook
      end
    end

    def register_passenger_hook
      @logger.info("Registered Phusion Passenger fork hook")
      PhusionPassenger.on_event(:starting_worker_process) do |forked|
        start_polling
      end
    end

    def register_unicorn_hook
      @logger.info("Registered Unicorn fork hook")
      poller = @poller
      Unicorn::HttpServer.class_eval do
        alias_method :worker_loop_without_copycopter, :worker_loop
        define_method :worker_loop do |worker|
          poller.start
          worker_loop_without_copycopter(worker)
        end
      end
    end

    def register_exit_hooks
      at_exit do
        @cache.flush
      end
    end

    def register_job_hooks
      if defined?(Resque::Job)
        @logger.info("Registered Resque after_perform hook")
        cache = @cache
        Resque::Job.class_eval do
          alias_method :perform_without_copycopter, :perform
          define_method :perform do
            job_was_performed = perform_without_copycopter
            cache.flush
            job_was_performed
          end
        end
      end
    end
  end
end
