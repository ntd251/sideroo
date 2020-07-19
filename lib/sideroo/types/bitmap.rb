module Sideroo
  class Bitmap < Base
    redis_methods %w[
      getbit
      setbit
    ]
  end
end
