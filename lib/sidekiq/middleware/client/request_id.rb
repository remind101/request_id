module Sidekiq
  module Middleware
    module Client
      class RequestId

        def call(worker, item, queue)
          item['request_id'] = request_id if request_id
          log(request_id, worker, item['args'].inspect) if log_request_id?(worker)
          yield
        end

      private

        def log(request_id, worker, args)
          logger.info "request_id=#{request_id} at=enqueue worker=#{worker.to_s} args=#{args}"
        end

        def log_request_id?(worker)
          worker.respond_to?(:get_sidekiq_options) && worker.get_sidekiq_options['log_request_id']
        end

        def logger
          Sidekiq.logger
        end

        def request_id
          Thread.current[:request_id]
        end

      end
    end
  end
end

