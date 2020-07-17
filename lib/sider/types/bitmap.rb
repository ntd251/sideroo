module Sider
  class Bitmap
    redis_methods %w[
      getbit
      setbit
    ]
  end
end
