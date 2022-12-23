require 'request_id/version'
require 'request_id/sidekiq' if defined?(Sidekiq)
require 'request_id/shoryuken' if defined?(Shoryuken)

module Rack
  autoload :RequestId, 'rack/request_id'
end

module RequestId
  autoload :Configuration, 'request_id/configuration'

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
      get(:request_id)
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
      set(:request_id, request_id)
    end

    # Public: Runs the block with the given request id set.
    #
    # Examples
    #
    #   RequestId.request_id
    #   # => "9fee77ec37b483983839fe7a753b64d9"
    #
    #   RequestId.with_request_id('c8ee330973663097f50686eb17d3324e') do
    #     RequestId.request_id
    #     # => "c8ee330973663097f50686eb17d3324e"
    #   end
    #
    #   RequestId.request_id
    #   # => "9fee77ec37b483983839fe7a753b64d9"
    def with_request_id(request_id, &block)
      with([ { key: :request_id, value: request_id } ], &block)
    end

    # Public: Runs the block with the given id key and value set.
    def with(kvs)
      last_kvs = kvs.map do |kv|
        last_id = RequestId.get(kv[:key])
        { key: kv[:key], value: last_id }
      end
      kvs.each do |kv|
        RequestId.set(kv[:key], kv[:value])
      end
      yield
    ensure
      last_kvs.each do |kv|
        RequestId.set(kv[:key], kv[:value])
      end
    end

    # Public: Retrieve the given id, which is generally set by the
    # Rack or Sidekiq middleware.
    def get(id_key)
      Thread.current[id_key]
    end

    # Public: Set the given id to the given value
    def set(id_key, id_value)
      Thread.current[id_key] = id_value
    end

    def configuration
      @configuration ||= Configuration.new
    end

    # Public: Configure RequestId.
    #
    # Examples
    #
    #   RequestId.configure do |config|
    #     config.generate = false
    #   end
    def configure
      yield configuration
    end
  end
end
