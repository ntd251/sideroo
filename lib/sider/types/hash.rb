module Sider
  class Hash < Base
    redis_methods %w[
      hdel
      hexists
      hget
      hgetall
      hincrby
      hincrbyfloat
      hkeys
      hlen
      hmget
      hmset
      hscan
      hscan_each
      hset
      hsetnx
      hvals
      mapped_hmget
      mapped_hmset
    ]
  end
end
