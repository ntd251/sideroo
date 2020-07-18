module Sider
  class Base
    class << self
      def redis_methods(method_names)
        method_names.each do |method_name|
          define_redis_method(method_name)
        end
      end

      # USAGE DEFINTIONS
      #
      def data_type(*args)
        @data_type = args.first if args.count > 0
        @data_type
      end

      def key_pattern(*args)
        @key_pattern = args.first if args.count > 0
        @key_pattern
      end

      def key_regex(*args)
        @key_regex = args.first if args.count > 0
        @key_regex || default_key_regex
      end

      ## METADATA
      #
      def example(*args)
        @example = args.first if args.count > 0
        @example
      end

      def description(*args)
        @description = args.first if args.count > 0
        @description
      end

      def key_attributes
        KeyBuilder.key_attributes(key_pattern)
      end

      def redis_client(*args)
        @redis_client = args.first if args.count > 0
        @redis_client || Sider.redis_client
      end

      ## SEARCH
      #
      def where(attr_map)
        Sider::Enumerator.new(
          type_klass: self,
          filters: attr_map,
        )
      end

      def all
        where({})
      end

      def build(attr_map)
        key = KeyBuilder.new(
          attr_map: attr_map,
          key_pattern: key_pattern,
        ).build

        new(key)
      end

      private

      def define_redis_method(method_name)
        define_method method_name do |*args|
          redis_args = [key].concat(args)
          # forward key and args to corresponding redis method
          redis_client.send(method_name, *redis_args)
        end
      end

      def default_key_regex
        regex_str = key_pattern

        key_attributes.each do |attr|
          term = "{#{attr}}"
          value = '.+'
          regex_str = regex_str.gsub(term, value)
        end

        Regexp.new("^#{regex_str}$")
      end
    end

    attr_reader :key

    def initialize(key)
      @key = key
    end

    def use_client(client)
      @redis_client = client
    end

    def redis_client
      @redis_client || self.class.redis_client
    end
  end
end
