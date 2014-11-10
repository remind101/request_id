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
      set_header(env) if needs_header?(env)
      @app.call(env)
    end

  private

    def needs_header?(env)
      ::RequestId.get(@options[:key]) && !env[:request_headers][@options[:header]]
    end

    def set_header(env)
      env[:request_headers][@options[:header]] = ::RequestId.get(@options[:key])
    end

    def default_options
      { key: :request_id, header: HEADER }
    end
  end
end
