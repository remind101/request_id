begin
  require 'sidekiq/middleware/server/logging'
rescue LoadError
  # No sidekiq
end

module Sidekiq
  module Middleware
    module Server
      class RequestId < Logging
        class << self
          attr_accessor :no_reset
        end

        def call(worker, item, queue)
          ::RequestId.request_id = item['request_id']
          yield
        ensure
          ::RequestId.request_id = nil unless self.class.no_reset
        end
      end
    end
  end
end
