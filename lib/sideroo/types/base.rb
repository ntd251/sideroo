module Sideroo
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
        if args.count > 0
          declare_key_pattern(args.first)
        end

        @key_pattern
      end

      def key_regex(*args)
        if args.count > 0
          custom_key_regex_should_be_defined_before_example!
          @key_regex = args.first
        end
        @key_regex || default_key_regex
      end

      ## METADATA
      #
      def example(*args)
        if args.count > 0
          @example = args.first
          validate_example!
        end
        @example
      end

      def description(*args)
        @description = args.first if args.count > 0
        @description
      end

      def key_attributes
        regex = /\{([^\{\}]+)\}/
        key_pattern.scan(regex).map(&:first)
      end

      alias_method :dimensions, :key_attributes

      def redis_client(*args)
        @redis_client = args.first if args.count > 0
        @redis_client || Sideroo.redis_client
      end

      ## SEARCH
      #
      def where(attr_map)
        Sideroo::Enumerator.new(
          type_klass: self,
          filters: attr_map,
        )
      end

      def all
        where({})
      end

      def count
        all.count
      end

      def flush
        all.each(&:del)
      end

      private

      def declare_key_pattern(pattern)
        raise Sideroo::PatternAlreadyDeclared unless key_pattern.nil?
        @key_pattern = pattern
        define_dimensions_as_attr_accessors
      end

      def define_dimensions_as_attr_accessors
        dimensions.each do |dimension|
          attr_accessor dimension
        end
      end

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
          value = '(.+)'
          regex_str = regex_str.gsub(term, value)
        end

        Regexp.new("^#{regex_str}$")
      end

      def custom_key_regex_should_be_defined_before_example!
        return if example.nil?
        message = 'Custom key regex should be defined before example'
        raise Sideroo::OutOfOrderConfig, message
      end

      def validate_example!
        example_valid = example.nil? || example =~ key_regex
        return if example_valid
        message = "Example does not match key regex: #{key_regex}"
        raise Sideroo::InvalidExample, message
      end
    end

    # Methods applied to all types
    redis_methods %w[
      del
      dump
      exists
      expire
      expireat
      persist
      pexpire
      pexpireat
      pttl
      rename
      renamenx
      restore
      touch
      ttl
      type
      unlink
    ]

    def initialize(arg = {})
      case arg
      when ::String
        raw_key = arg
        key_regex = self.class.key_regex

        message = "Expected pattern #{key_pattern}, got #{arg}"
        raise(ArgumentError, message) if raw_key !~ key_regex

        values = raw_key.scan(key_regex).first
        self.class.dimensions.zip(values).each do |dimension, value|
          send("#{dimension}=", value)
        end
      when ::Hash
        attr_map = arg
        attr_map.each do |dimension, value|
          send("#{dimension}=", value)
        end
      else
        message = "Hash or String expected. #{arg.class} given."
        raise ArgumentError, message
      end
    end

    def key
      k = key_pattern

      self.class.dimensions.each do |dimension|
        term = "{#{dimension}}"
        value = send(dimension)
        k = k.gsub(term, value.to_s)
      end

      k
    end

    def redis_client=(client)
      @redis_client = client
    end

    def redis_client
      @redis_client || self.class.redis_client
    end

    private

    def key_pattern
      self.class.key_pattern
    end

    def validate_attrs!(attr_map)
      provided_attrs = attr_map.keys.map(&:to_s)
      key_attributes = self.class.key_attributes(key_pattern)

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
  end
end
