module Rack

  # Public: Rack middleware that stores the Heroku-Request-Id header in a
  # thread local variable.
  #
  # Heroku has a labs feature called request_id, which can be used to tracking
  # a request through the system.
  #
  # app - The Rack app.
  #
  # Examples
  #
  #   use Rack::LogRequestId
  #
  #   logger.info "request_id=#{Thread.current[:request_id]} Hello world"
  #   # => request_id=a08a6712229fb991c0e5026c246862c7 Hello world
  class RequestId
    REQUEST_ID_HEADER = 'HTTP_HEROKU_REQUEST_ID'.freeze

    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      ::RequestId.request_id = env[REQUEST_ID_HEADER]
      @app.call(env)
    ensure
      ::RequestId.request_id = nil
    end
  end
end
