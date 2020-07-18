module Sider
  class SortedSet
    redis_methods %w[
      zadd
      zcard
      zcount
      zincrby
      zlexcount
      zpopmax
      zpopmin
      zrange
      zrangebylex
      zrangebyscore
      zrank
      zrem
      zremrangebyrank
      zremrangebyscore
      zrevrange
      zrevrangebylex
      zrevrangebyscore
      zrevrank
      zscan
      zscan_each
      zscore
    ]

    def zinterstore(destination, *other_keys)
      redis_client.zinterstore(destination, key, *other_keys)
    end

    # Use `self.key` as destination
    def zinterstore!(*other_keys)
      redis_client.zinterstore(key, *other_keys)
    end

    def zunionstore(destination, *other_keys)
      redis_client.zunionstore(destination, key, *other_keys)
    end

    # Use `self.key` as destination
    def zunionstore!(*other_keys)
      redis_client.zunionstore(key, *other_keys)
    end
  end
end