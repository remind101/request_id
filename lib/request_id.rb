require 'request_id/version'

module Rack
  autoload :RequestId, 'rack/request_id'
end

module Sidekiq
  module Middleware
    module Client
      autoload :RequestId, 'sidekiq/middleware/client/request_id'
    end
  end
end
