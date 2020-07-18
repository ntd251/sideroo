module Sider
  class Set < Redis
    redis_methods %w[
      sadd
      scard
      sdiff
      sinter
      sismember
      smembers
      smove
      spop
      srandmember
      srem
      sscan
      sscan_each
      sunion
    ]
  end

  def sdiffstore(destination, *other_keys)
    redis_client.sdiffstore(destination, key, *other_keys)
  end

  # Use `self.key` as destination
  def sdiffstore!(*other_keys)
    redis_client.sdiffstore(key, *other_keys)
  end

  def sinterstore(destination, *other_keys)
    redis_client.sinterstore(destination, key, *other_keys)
  end

  # Use `self.key` as destination
  def sinterstore!(*other_keys)
    redis_client.sinterstore(key, *other_keys)
  end

  def sunionstore(destination, *other_keys)
    redis_client.sunionstore(destination, key, *other_keys)
  end

  # Use `self.key` as destination
  def sunionstore!(*other_keys)
    redis_client.sunionstore(key, *other_keys)
  end
end