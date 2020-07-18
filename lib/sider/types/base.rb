module Sider
  class Base
    class << self
      def redis_methods(method_names)
        method_names.each do |method_name|
          define_redis_method(method_name)
        end
      end

      def key_pattern(*args)
        @key_pattern ||= args.first
      end

      def key_attributes
        regex = /\{([^\{\}]+)\}/
        key_pattern.scan(regex).map(&:first)
      end

      def redis_client(*args)
        @redis_client ||= args.first || Sider.redis_client
      end

      def description(*args)
        @description ||= args.first
      end

      private

      def define_redis_method(method_name)
        define_method method_name do |*args|
          redis_args = [key].concat(args)
          # forward key and args to corresponding redis method
          redis_client.send(method_name, *redis_args)
        end
      end
    end

    attr_reader :key

    def initialize(attr_map = {})
      validate_attrs!(attr_map)
      @key = populate_key(attr_map)
    end

    def use_client(client)
      @redis_client = client
    end

    def redis_client
      @redis_client || self.class.redis_client
    end

    private

    def validate_attrs!(attr_map)
      key_attributes = self.class.key_attributes
      provided_attrs = attr_map.keys.map(&:to_s)

      missing_attrs = key_attributes - provided_attrs
      unexpected_attrs = provided_attrs - key_attributes

      if missing_attrs.any?
        msg = "Missing attributes: #{missing_attrs.join(', ')}"
        raise MissingKeys, msg
      end

      if unexpected_attrs.any?
        msg = "Unexpected attributes: #{unexpected_attrs.join(', ')}"
        raise UnexpectedKeys, msg
      end
    end

    def populate_key(attr_map)
      key = self.class.key_pattern
      attr_map.each do |attr, value|
        term = "{#{attr}}"
        key = key.gsub(term, value.to_s)
      end

      key
    end
  end
end
