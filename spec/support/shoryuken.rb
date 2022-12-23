require 'logger'

module Shoryuken
  def self.logger
    @logger ||= ::Logger.new($stdout)
  end
end
