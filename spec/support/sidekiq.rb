require 'logger'

module Sidekiq
  def self.logger
    @logger ||= ::Logger.new(STDOUT)
  end
end

# https://github.com/mperham/sidekiq/blob/aa9745e9b29d408ac423356af50859cb9c382135/lib/sidekiq/job_logger.rb
module Sidekiq
  class JobLogger
    def elapsed(start)
      (Time.now - start).to_f.round(3)
    end

    def logger
      Sidekiq.logger
    end
  end
end

# https://github.com/mperham/sidekiq/blob/602d5da96d0101f47d7e89602478b2246853733e/lib/sidekiq/logging.rb
module Sidekiq
  module Logging
    def self.with_context(msg)
      yield
    end
  end
end
