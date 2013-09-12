module RequestId
  class Configuration
    # If set to true, the rack middleware will automatically generate a request
    # id. Useful in development. Defaults to true if this is a rails app an
    # we're in development.
    attr_accessor :generate

    def initialize
      @generate = defined?(Rails) && Rails.env.development?
    end
  end
end
