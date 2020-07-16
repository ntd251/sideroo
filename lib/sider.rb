require "sider/version"
require "sider/types/base"

module Sider
  class Error < StandardError; end

  class Configuration
    attr_accessor :redis_client
  end

  class << self
    def configure
      @config = Configuration.new
      yield(@config)
    end

    def redis_client
      @config.redis_client
    end
  end
end
