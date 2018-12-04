begin
  require 'sidekiq/job_logger'
rescue LoadError
  # No sidekiq
end

module Sidekiq
  module Middleware
    module Server
      class RequestId < ::Sidekiq::JobLogger
        class << self
          attr_accessor :no_reset
        end

        def initialize(options = nil)
          @options = options || default_options
        end

        def call(worker, item, queue)
          @options[:headers].each do |kv|
            ::RequestId.set(kv[:key], kv[:value].call(item))
          end
          yield
        ensure
          @options[:headers].each do |kv|
            ::RequestId.set(kv[:key], nil) unless self.class.no_reset
          end
        end

        private

          def default_options
            { headers: [ { key: :request_id, value: lambda { |item| item['request_id'] } } ] }
          end
      end
    end
  end
end
