module Sideroo
  class HyperLogLog < Base
    redis_methods %w[
      pfadd
      pfcount
    ]

    def pfmerge(destination, *other_keys)
      redis_client.pfmerge(destination, key, *other_keys)
    end

    # Use `self.key` as destination
    def pfmerge!(*other_keys)
      redis_client.pfmerge(key, *other_keys)
    end
  end
end
