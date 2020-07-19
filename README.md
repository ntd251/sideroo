# Sider

## 1. Motivations

This gem is aimed to provide
- a **declarative** and **auditable** approach when working with Redis
- **self-generated documentation** for your Redis usages
- **object-oriented** methods for each Redis data type

while maintaining a **thin** abstraction on top of `redis` gem.

```rb
class TopStoriesCache < Sider::Set
  key_pattern 'top_stories:{country}:{category}'
  description 'Cache top stories by ID per country and category'
  example 'top_stories:us:romance'
end

cache = TopStoriesCache.new(country: 'us', category: 'romance')

cache.sadd(story_id)
cache.smembers
cache.sismember(member)
```

## 2. Installation

Add this line to your application's Gemfile:

```ruby
gem 'sider'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sider


## 3. Usage

### 3.0. Configurations - REQUIRED

```rb
Sider.configure do |c|
  c.redis_client = Redis.new
end
```

Sider provides a thin OOP abstraction on top of `redis-rb`. Therefore, it's recommended to use `redis-rb` (with / without `redis-namespace`). Any Redis clients with the same interfaces are fine too.

Most of the usage are just to abstract the `key` argument into the internal state of the obj.

#### Examples

For Redis `Set`

```rb
# in Redis
key = "namespace:#{dimension_1}:#{dimension_2}"
redis_client.scard(key)
redis_client.sadd(key, member)

# in Sider
class MySet < Sider::Set
  key_pattern 'namespace:{dimension_1}:{dimension_2}'
end

sider_set = MySet.new(
  dimension_1: value_1,
  dimension_2: value_2,
)
sider_set.scard
sider_set.sadd(member)
```

### 3.1. Define a Redis usage

Each Redis usages usually
- have a key pattern
- use a certain Redis data type

`Sider` provides what you need and more.

There are some configurations you can specify for each use-cases.

#### `key_pattern` - String - required

Pattern used by the use-case

```rb
key_pattern 'top_stories:{country}:{category}'
```

#### `key_regex` - Regexp - optional

Regex for better pattern matching for search. See more in Section 5.

Can be 100% optional if key namespacing is done well.

```rb
key_regex /^top_stories\:(\w{2})\:([^\:]+)$/
```

#### `description` - String - optional

Provide description to the use-cases.

```rb
description 'Cache top stories per country and category'
```

#### `example` - String - optional

Example of actual Redis keys would be used. If specified, you can utilize `example_valid?` check to validate `key_regex` in your specs.

```rb
example 'top_stories:us:romance'
```

#### Dynamic initalization

When there are dynamic components inside the key pattern, e.g. `top_stories:{country}:{category}`, the constructor would detect and require `country` and `category` during initialization.


```rb
# Static cache key
class TopUserCache < Sider::List
  key_pattern 'top_users' # REQUIRED
  description 'Cache 50 top users worldwide'
end

# 1-dimension cache key
class CountryPolicyCache < Sider::String
  key_pattern 'policy:{country}' # REQUIRED
  key_regex /^page\:(\w{2})$/ # Optional. To resolve key conflicts with other usages if any.
  description 'Cache Policy page per country'
end

CountryPolicyCache.new # MissingKeys: Missing country
CountryPolicyCache.new(country: 'us') # Good
CountryPolicyCache.new(gender: 'us') # UnexpectedKeys: Unexpected keys gender

# 2-dimension cache key
class TopStoriesCache < Sider::List
  key_pattern 'top_stories:{country}:{category}'
  description 'Cache top stories by ID per country and category'
end

TopStoriesCache.new # MissingKeys: Missing country, category
TopStoriesCache.new(country: 'us') # MissingKeys: Missing category
TopStoriesCache.new(country: 'us', category: 'romance') # GOOD
TopStoriesCache.new(country: 'us', cateogry: 'romance', random_key: 'random_value') # UnexpectedKeys: Unexpected keys random_key
```

### 3.2. Object-oriented methods for each data type

```rb
class CountryPageCache < Sider::String
  key_pattern 'page:{country}'
  key_regex /^page\:(\w{2})$/
end

# The key-value params are auto detected
page_cache = CountryPageCache.new(country: country)
page_cache.get

class TopStoriesCache < Sider::List
  key_pattern 'top_stories:{country}:{category}'
  description 'Cache top stories by ID per country and category'
end

# The key-value params are auto detected
cache = TopStoryCache.new(country: 'sg', category: 10)
cache.lpush(story_id)
cache.set(story_id) # NoMethodError - since `set` is not a method of List type
```

### 3.3. Search and Enumerable

```rb
class TopStoriesCache < Sider::Set
  key_pattern 'top_stories:{country}:{category}'
  description 'Cache top stories by ID per country and category'
end
```

```
top_stories:sg:10
top_stories:sg:20
top_stories:us:10
top_stories:us:12
```

```rb
TopStoriesCache.all # Not recommended for large db
TopStoriesCache.all.to_a

TopStoriesCache.where(country: 'sg').to_a

# Loop through `top_stories:sg:*`
TopStoriesCache.where(country: 'sg').each do |list|
  list.key # top_stories:sg:10
  list.smembers # return story ids
  # ...
end

TopStoriesCache.where(country: 'sg').map do |list|
  #...
end

TopStoriesCache.where(country: 'sg').count
```

### 3.4. Report & Generate documentation - COMING SOON

```rb
Sider.report
```

```
TBD
```

### 3.5. Audit keys

```rb
TopStoriesCache.count # Scan and count

TopStoriesCache.all.to_a # NOT RECOMMENDED if there are too many keys
```

### 3.6. Flush keys - COMING SOON

```rb
TopStoriesCache.flush # Delete all keys of TopStoriesCache
```

---

## 4. Data Types

`Sider` provides support for 7 main Redis data types.

All `key`-related Redis methods are supported by all below types.

### KEY-related methods

```rb
class AnyRecord < Sider::Base
  # ...
end

record = AnyRecord.new(...)

record.del
record.dump
record.exists
record.expire(duration_in_seconds)
record.expireat(time_in_seconds)
record.persist
record.pexpire(duration_in_ms)
record.pexpireat(time_in_ms)
record.pttl
record.rename(new_key)
record.renamenx(new_key)
record.restore(ttl, serialized_value, options)
record.touch
record.ttl
record.type
record.unlink
```

### 4.1. `Sider::String`

Support all KEY-related methods and its own methods.

```rb
class MyStringCache < Sider::String
  # ...
end

string = MyStringCache.new(...)

string.append(value)
string.decr
string.decrby(value) # number
string.get
string.getbit(offset)
string.getrange(start, stop)
string.getset(value)
string.incr
string.incrby(value)
string.incrbyfloat(value)
string.psetex(ttl, value)
string.set(value)
string.setbit(offset, value)
string.setex(ttl, value)
string.setnx(value)
string.setrange(offset, value)
string.strlen
```

### 4.2. `Sider::Hash`

Support all KEY-related methods and its own methods.

```rb
class MyHash < Sider::Hash
  # ...
end

hash = MyHash.new(...)

hash.hdel(*fields)
hash.hexists(field)
hash.hget(field)
hash.hgetall
hash.hincrby(field, increment)
hash.hincrbyfloat(field, increment)
hash.hkeys
hash.hlen
hash.hmget(*fields, &blk)
hash.hmset(*attrs)
hash.hscan(cursor, options = {})
hash.hscan_each(options = {}, &block)
hash.hset(field, value)
hash.hsetnx(field, value)
hash.hvals
hash.mapped_hmget(*field)
hash.mapped_hmset(hash)
```

### 4.3. `Sider::List`

Support all KEY-related methods and its own methods.

```rb
class MyList < Sider::List
  # ...
end

list = MyList.new(...)

list.blpop(timeout:)
list.brpop(timeout:)
list.brpoplpush(destination, options = {})
list.lindex(index) # => String
list.linsert(where, pivot, value) # => Fixnum
list.llen # => Fixnum
list.lpop # => String
list.lpush(value) # => Fixnum
list.lpushx(value) # => Fixnum
list.lrange(start, stop) # => Array<String>
list.lrem(count, value) # => Fixnum
list.lset(index, value) # => String
list.ltrim(start, stop) # => String
list.rpop # => String
list.rpoplpush(source, destination) # => nil, String
list.rpush(value) # => Fixnum
list.rpushx(value) # => Fixnum
```

### 4.4. `Sider::Set`

Support all KEY-related methods and its own methods.

```rb
class SiteSet < Sider::Set
  # ...
end

set = SiteSet.new(...)

set.sadd(member) # => Boolean, Fixnum
set.scard
set.sdiff(*other_keys)
set.sinter(*other_keys)
set.sismember(member)
set.smembers
set.smove(destination, member)
set.spop(count = nil)
set.srandmember(count = nil)
set.srem(member)
set.sscan(cursor, options = {}) # => String+
set.sscan_each(options = {}, &block) # => Enumerator
set.sunion(*other_keys)
set.sdiffstore(destination, *other_keys)
set.sdiffstore!(*other_keys)
set.sinterstore(destination, *other_keys)
set.sinterstore!(*other_keys)
set.sunionstore(destination, *other_keys)
set.sunionstore!(*other_keys)
```

### 4.5. `Sider::SortedSet`

Support all KEY-related methods and its own methods.

```rb
class MySortedSet < Sider::SortedSet
  # ...
end

sorted_set = MySortedSet.new(...)

sorted_set.zadd(*args) # => Boolean, ...
sorted_set.zcard # => Fixnum
sorted_set.zcount(min, max) # => Fixnum
sorted_set.zincrby(increment, member) # => Float
sorted_set.zlexcount(min, max) # => Fixnum
sorted_set.zpopmax(count = nil) # => Array<String, Float>+
sorted_set.zpopmin(count = nil) # => Array<String, Float>+
sorted_set.zrange(start, stop, options = {}) # => Array<String>, Arra
sorted_set.zrangebylex(min, max, options = {}) # => Array<String>, Arra
sorted_set.zrangebyscore(min, max, options = {}) # => Array<String>, Arra
sorted_set.zrank(member) # => Fixnum
sorted_set.zrem(member) # => Boolean, Fixnum
sorted_set.zremrangebyrank(start, stop) # => Fixnum
sorted_set.zremrangebyscore(min, max) # => Fixnum
sorted_set.zrevrange(start, stop, options = {}) # => Object
sorted_set.zrevrangebylex(max, min, options = {}) # => Object
sorted_set.zrevrangebyscore(max, min, options = {}) # => Object
sorted_set.zrevrank(member) # => Fixnum
sorted_set.zscan(cursor, options = {}) # => String, Arra
sorted_set.zscan_each(options = {}, &block) # => Enumerator
sorted_set.zscore(member) # => Float
sorted_set.zinterstore(destination, *other_keys)
sorted_set.zinterstore!(*other_keys)
sorted_set.zunionstore(destination, *other_keys)
sorted_set.zunionstore!(*other_keys)
```

### 4.6. `Sider::Bitmap`

Support all KEY-related methods and its own methods.

```rb
class MyBitmap < Sider::Bitmap
  # ...
end

bitmap = MyBitmap.new(...)

bitmap.getbit(offset)
bitmap.setbit(offset, value)
```

### 4.7. `Sider::HyperLogLog`

Support all KEY-related methods and its own methods.

```rb
class MyHLL < Sider::HyperLogLog
  # ...
end

hll = MyHLL.new(...)

hll.pfadd(member)
hll.pfcount
hll.pfmerge(destination, *other_keys)
hll.pfmerge!(*other_keys)
```

---

## 5. Known issues

### 5.1. Key conflicts on search

Redis search via `keys` and `scan` methods only support `glob`-style patterns.

- `h?llo` matches `hello`, `hallo` and `hxllo`
- `h*llo` matches `hllo` and `heeeello`
- `h[ae]llo` matches `hello` and `hallo`, but not `hillo`
- `h[^e]llo` matches `hallo`, `hbllo`, ... but not `hello`
- `h[a-b]llo` matches `hallo` and `hbllo`

`glob`-style patterns are not as comprehensive as Regexp. This introduces conflicts for similar key patterns.

For examples,

- `users:{country}:{gender}` would use search pattern `users:*:*`
- `users:{age}` would use search pattern `users:*`

The second pattern does cover the data set of the first pattern. This could be avoid by having better namespacing in your applications.

e.g.`ucg:{country}:{gender}` vs. `u:{user_id}`.

`Sider` also provides an additional matching options called `key_regex` for each `class`. This would allow deeper key selection.

```rb
class TopCountryGenderUsersCache < Sider::Set
  key_pattern 'users:{country}:{gender}'
  key_regex /^users\:([a-z]{2})\:([mf])$/
  example 'users:sg:m'
  description 'Top users per country per gender'
end

class UserStoriesCache < Sider::Set
  key_pattern 'users:{user_id}'
  key_regex /^users\:\d+$/
  example 'users:12345'
  description 'Top stories per users'
end
```

## 6. Redis Clients

Redis clients can be customized at 3 levels
- Global
- Class
- Instance

The lower level would inherit the config from parent level if a custom Redis client is not specified.

### 6.1. Global `Sider` config

```rb
Sider.configure do |c|
  c.redis_client = global_redis_client
end
```

### 6.2. Class level config

```rb
class UserStoriesCache < Sider::Set
  # ...
  redis_client class_redis_client
end
```

### 6.3. Instance level config

```rb
cache = UserStoriesCache.new(...)
cache.use_client(instance_redis_client)
```


## 7. Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## 8. Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sider. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/sider/blob/master/CODE_OF_CONDUCT.md).


## 9. License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 10. Code of Conduct

Everyone interacting in the Sider project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sider/blob/master/CODE_OF_CONDUCT.md).
