module Sidekiq
  module Middleware
    module Server
      class RequestId

        def call(worker, item, queue)
          request_id = Thread.current[:request_id] = item['request_id']
          log(request_id, worker, item['args'].inspect) if log_request_id?(item)
          yield
        ensure
          Thread.current[:request_id] = nil
        end

      private

        def log(request_id, worker, args)
          logger.info "request_id=#{request_id} at=start worker=#{worker.to_s} args=#{args}"
        end

        def log_request_id?(item)
          item['log_request_id']
        end

        def logger
          Sidekiq.logger
        end

      end
    end
  end
end
