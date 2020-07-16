module Sider
  class Base
    class << self
      def redis_methods(method_names)
        method_names.each do |method_name|
          define_redis_method(method_name)
        end
      end

      def key_pattern(*args)
        return @key_pattern if args.count.zero?
        set_key_pattern(*args)
      end

      def redis_client(*args)
        return set_redis_client(*args) unless args.count.zero?
        @redis_client || Sider.redis_client
      end

      private

      def define_redis_method(method_name)
        define_method method_name do |*args|
          redis_args = [key].concat(args)
          puts(method_name, *redis_args)
        end
      end

      def set_key_pattern(pattern)
        @key_pattern = pattern
      end

      def set_redis_client(client)
        @redis_client = client
      end
    end

    attr_reader :key

    def initialize(attr_map = {})
      @key = populate_key(attr_map)
    end

    def use_client(client)
      @redis_client = client
    end

    def redis_client
      @redis_client || self.class.redis_client
    end

    private

    def populate_key(attr_map)
      key_pattern = self.class.key_pattern

      regex = /\{([^\{\}]+)\}/
      keys = key_pattern.scan(regex).map(&:first)
      provided_keys = attr_map.keys.map(&:to_s)

      missing_keys = keys - provided_keys
      unexpected_keys = provided_keys - keys

      if missing_keys.any?
        msg = "Missing keys: #{missing_keys.join(', ')}"
        raise MissingKeys, msg
      end

      if unexpected_keys.any?
        msg = "Unexpected keys: #{unexpected_keys.join(', ')}"
        raise UnexpectedKeys, msg
      end

      key = key_pattern
      attr_map.each do |attr, value|
        term = "{#{attr}}"
        key = key.gsub(term, value.to_s)
      end

      key
    end
  end
end
