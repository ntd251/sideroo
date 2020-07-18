module Sider
  class Enumerator
    attr_reader :type_klass
    attr_reader :limit
    attr_reader :redis_client

    attr_reader :filters
    attr_reader :search_pattern

    def initialize(type_klass:, filters:, limit: -1)
      @type_klass = type_klass
      @limit = limit
      @redis_client = redis_client || Sider.redis_client
      @filters = stringify_keys(filters)

      @search_pattern = build_search_pattern
    end

    def each
      cursor = nil
      count = 0

      until cursor.to_s == '0'
        cursor ||= 0
        cursor, keys = redis_client.scan(cursor, match: search_pattern)

        keys.each do |key|
          break if exceed_limit?(count)
          next unless regex_matched?(key)

          count += 1
          item = type_klass.new(key)
          yield(item)
        end
      end
    end

    def map
      output = []
      each do |obj|
        output.push(obj)
      end
      output
    end

    def count
      count = 0
      each { count += 1 }
      count
    end

    def to_a
      map { |item| item }
    end

    private

    def exceed_limit?(count)
      limit >= 0 && count > limit
    end

    def regex_matched?(key)
      key =~ type_klass.key_regex
    end

    def build_search_pattern
      search_pattern = type_klass.key_pattern

      type_klass.key_attributes.each do |attr|
        value = filters[attr]
        value = value.nil? ? '*' : value.to_s

        term = "{#{attr}}"
        search_pattern = search_pattern.gsub(term, value.to_s)
      end
      search_pattern
    end

    def stringify_keys(raw_attr_map)
      raw_attr_map.map { |k, v| [k.to_s, v] }.to_h
    end
  end
end
