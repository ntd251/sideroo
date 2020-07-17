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
      hset
      hsetnx
      hvals
    ]
  end
end