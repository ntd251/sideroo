require "sider/version"
require "sider/types/base"
require "sider/types/string"

module Sider
  class Error < StandardError; end
  class MissingKeys < ArgumentError; end
  class UnexpectedKeys < ArgumentError; end

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
