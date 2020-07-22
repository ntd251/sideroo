require "sideroo/version"
require "sideroo/enumerator"
require "sideroo/types/base"
require "sideroo/types/bitmap"
require "sideroo/types/hash"
require "sideroo/types/hyper_log_log"
require "sideroo/types/list"
require "sideroo/types/set"
require "sideroo/types/sorted_set"
require "sideroo/types/string"

module Sideroo
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
