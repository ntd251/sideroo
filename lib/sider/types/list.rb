module Sider
  class List < Base
    redis_methods %w[
      blpop
      brpop
      brpoplpush
      lindex
      linsert
      llen
      lpop
      lpush
      lpushx
      lrange
      lrem
      lset
      ltrim
      rpop
      rpoplpush
      rpush
      rpushx
    ]
  end
end
