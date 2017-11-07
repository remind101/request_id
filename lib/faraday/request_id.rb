require 'request_id'
require 'faraday'

module Faraday
  class RequestId < Faraday::Middleware
    HEADER = 'X-Request-Id'.freeze

    def initialize(app, options = nil)
      super(app)
      @options = options || default_options
    end

    def call(env)
      @options[:headers].each do |header|
        set_header(env, header) if needs_header?(env, header)
      end
      @app.call(env)
    end

  private

    def needs_header?(env, header)
      ::RequestId.get(header[:key]) && !env[:request_headers][header[:header]]
    end

    def set_header(env, header)
      env[:request_headers][header[:header]] = ::RequestId.get(header[:key])
    end

    def default_options
      { headers: [ { key: :request_id, header: HEADER } ] }
    end
  end
end
