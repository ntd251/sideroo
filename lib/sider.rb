require "sider/version"
require "sider/enumerator"
require "sider/key_builder"
require "sider/types/base"
require "sider/types/bitmap"
require "sider/types/hash"
require "sider/types/hyper_log_log"
require "sider/types/list"
require "sider/types/set"
require "sider/types/sorted_set"
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
