require 'securerandom'

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
    REQUEST_HEADER  = 'HTTP_X_REQUEST_ID'.freeze
    RESPONSE_HEADER = 'X-Request-Id'.freeze

    def initialize(app, options = {})
      @app = app
    end

    def call(env)
      ::RequestId.with_request_id(request_id(env)) do
        status, headers, body = @app.call(env)
        headers[RESPONSE_HEADER] ||= ::RequestId.request_id
        [status, headers, body]
      end
    end

  private

    def request_id(env)
      env[REQUEST_HEADER] || generate
    end

    def generate
      generate? && SecureRandom.hex(16)
    end

    def generate?
      ::RequestId.configuration.generate
    end

  end
end
