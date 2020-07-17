module Sider
  class String < Base
    redis_methods %w[
      append
      decr
      decrby
      get
      getbit
      getrange
      getset
      incr
      incrby
      incrbyfloat
      mget
      mset
      msetnx
      psetex
      set
      setbit
      setex
      setnx
      setrange
      strlen
    ]
  end
end
