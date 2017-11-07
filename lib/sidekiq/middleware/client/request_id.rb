module Sidekiq
  module Middleware
    module Client
      class RequestId
        def initialize(options = nil)
          @options = options || default_options
        end

        def call(worker, item, queue, redis_pool = nil)
          @options[:headers].each do |kv|
            item[kv[:key].to_s] = kv[:value].call() if kv[:value]
          end
          yield
        end

      private

        def default_options
          { headers: [ { key: :request_id, value: lambda { ::RequestId.request_id } } ] }
        end
      end
    end
  end
end

