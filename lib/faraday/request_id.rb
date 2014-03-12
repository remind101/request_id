require 'request_id'
require 'faraday'

module Faraday
  class RequestId < Faraday::Middleware
    HEADER = 'X-Request-Id'.freeze

    def call(env)
      set_header(env) if needs_header?(env)
      @app.call(env)
    end

  private

    def needs_header?(env)
      request_id && !env[:request_headers][HEADER]
    end

    def set_header(env)
      env[:request_headers][HEADER] = request_id
    end

    def request_id
      ::RequestId.request_id
    end
  end
end
