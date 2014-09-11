module Sidekiq
  module Middleware
    module Client
      class RequestId
        def call(worker, item, queue)
          item['request_id'] = request_id if request_id
          yield
        end

      private

        def request_id
          ::RequestId.request_id
        end
      end
    end
  end
end

