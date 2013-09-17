require 'request_id/version'
require 'request_id/sidekiq' if defined?(Sidekiq)

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
    def with_request_id(request_id)
      last_request_id = RequestId.request_id
      RequestId.request_id = request_id
      yield
    ensure
      RequestId.request_id = last_request_id
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
