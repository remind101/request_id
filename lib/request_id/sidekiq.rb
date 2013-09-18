module Sidekiq
  module Middleware
    module Client
      autoload :RequestId, 'sidekiq/middleware/client/request_id'
    end

    module Server
      autoload :RequestId, 'sidekiq/middleware/server/request_id'
    end
  end
end
