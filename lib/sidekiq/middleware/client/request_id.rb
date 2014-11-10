module Sidekiq
  module Middleware
    module Client
      class RequestId
        def initialize(options = nil)
          @options = options || default_options
        end

        def call(worker, item, queue)
          item[id_key] = id_value if id_value
          yield
        end

      private

        def id_key
          @options[:key].to_s
        end

        def id_value
          @options[:value].call()
        end

        def default_options
          { key: :request_id, value: lambda { ::RequestId.request_id } }
        end
      end
    end
  end
end

