module Sideroo
  class KeyBuilder
    attr_reader :attr_map
    attr_reader :key_pattern

    class << self
      def key_attributes(key_pattern)
        regex = /\{([^\{\}]+)\}/
        key_pattern.scan(regex).map(&:first)
      end
    end

    def initialize(attr_map:, key_pattern:)
      @attr_map = attr_map
      @key_pattern = key_pattern
    end

    def build
      validate_attrs!
      populate_key
    end

    private

    def validate_attrs!
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

    def populate_key
      key = key_pattern
      attr_map.each do |attr, value|
        term = "{#{attr}}"
        key = key.gsub(term, value.to_s)
      end

      key
    end
  end
end