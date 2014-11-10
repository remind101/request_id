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

        def initialize(options = nil)
          @options = options || default_options
        end

        def call(worker, item, queue)
          ::RequestId.set(@options[:key], @options[:value].call(item))
          yield
        ensure
          ::RequestId.set(@options[:key], nil) unless self.class.no_reset
        end

        private

          def default_options
            { key: :request_id, value: lambda { |item| item['request_id'] } }
          end
      end
    end
  end
end
