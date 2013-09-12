require 'request_id/version'

module RequestId
  class << self

    # Public: Retrieve the current request_id, which is generally set by the
    # Rack or Sidekiq middleware.
    #
    # Examples
    #
    #   RequestId.request_id
    #   # => "0b482498be0d6084d2b634cd6523418d"
    #
    # Returns the String request id.
    def request_id
      Thread.current[:request_id]
    end

    # Internal: Set the current request_id.
    #
    # Examples
    #
    #   RequestId.request_id = SecureRandom.hex
    #   # => "2297456c027c536d0eb3eb86583fe5a9"
    #
    # Returns the new String request id.
    def request_id=(request_id)
      Thread.current[:request_id] = request_id
    end

  end
end

module Rack
  autoload :RequestId, 'rack/request_id'
end

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
