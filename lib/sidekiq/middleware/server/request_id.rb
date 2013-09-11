module Sidekiq
  module Middleware
    module Server
      class RequestId < Logging

        def call(worker, item, queue)
          request_id = Thread.current[:request_id] = item['request_id']
          Sidekiq::Logging.with_context("request_id=#{request_id} worker=#{worker.class.to_s} jid=#{item['jid']} args=#{item['args'].inspect}") do
            begin
              start = Time.now
              logger.info { "at=start" }
              yield
              logger.info { "at=done duration=#{elapsed(start)}sec" }
            rescue Exception
              logger.info { "at=fail duration=#{elapsed(start)}sec" }
              raise
            end
          end
        ensure
          Thread.current[:request_id] = nil
        end

      end
    end
  end
end
