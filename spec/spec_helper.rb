require "bundler/setup"
require "sider"
require "redis"
require 'redis-namespace'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    Sider.configure do |c|
      c.redis_client = Redis::Namespace.new('sider-specs', redis: Redis.new)
    end
  end

  config.after(:each) do
    Sider.redis_client.flushdb
  end
end

