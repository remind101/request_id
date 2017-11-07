require 'securerandom'

module Rack

  # Public: Rack middleware that stores the X-Request-Id header in a
  # thread local variable.
  #
  # Heroku has a labs feature called request_id, which can be used to tracking
  # a request through the system.
  #
  # app - The Rack app.
  #
  # Examples
  #
  #   use Rack::RequestId, headers: [ { key: :request_id, value: -> (env) { env['HTTP_X_REQUEST_ID'] }, response_header: 'X-Request-Id' } ]
  #
  #   logger.info "request_id=#{RequestId.request_id} Hello world"
  #   # => request_id=a08a6712229fb991c0e5026c246862c7 Hello world
  class RequestId
    REQUEST_HEADER  = 'HTTP_X_REQUEST_ID'.freeze
    RESPONSE_HEADER = 'X-Request-Id'.freeze

    def initialize(app, options = nil)
      @app = app
      @options = options || default_options
    end

    def call(env)
      ::RequestId.with(options_with_resolved_values(env)) do
        status, headers, body = @app.call(env)

        @options[:headers].each do |h|
          if h[:response_header]
            headers[h[:response_header]] ||= ::RequestId.get(h[:key]).to_s
          end
        end

        [status, headers, body]
      end
    end

  private

    def options_with_resolved_values(env)
      @options[:headers].map do |header|
        { key: header[:key], value: header[:value].call(env) || generate}
      end
    end

    def default_options
      { headers: [ { key: :request_id, value: lambda { |env| env[REQUEST_HEADER] }, response_header: RESPONSE_HEADER } ] }
    end

    def generate
      SecureRandom.uuid if ::RequestId.configuration.generate
    end

  end
end
