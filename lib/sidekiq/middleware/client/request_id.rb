module Sidekiq
  module Middleware
    module Client
      class RequestId

        def call(worker, item, queue)
          if log_request_id?(worker)
            item['request_id'] = request_id = Thread.current[:request_id]
            logger.info "request_id=#{request_id} at=enqueue worker=#{worker.to_s} args=#{item['args'].inspect}"
          end
          yield
        end

      private

        def log_request_id?(worker)
          worker.respond_to?(:get_sidekiq_options) && worker.get_sidekiq_options['log_request_id']
        end

        def logger
          Sidekiq.logger
        end

      end
    end
  end
end

