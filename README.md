# Sider

## 1. Motivations

This gem is aimed to provide
- a more declarative and auditable approach when working with Redis.
- self-generated documentation for your Redis usages
- object-oriented methods for each Redis data type

while
- maintaining thin abstraction on top of `redis` gem.

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

### 3.1. Define a Redis usage

Each Redis usages usually
- have a key pattern
- use a certain Redis data type

`Sider` provides what you need and more.

When there are dynamic components inside the key pattern, e.g. `top_stories:{country}:{category}`,
the constructor would detect and require `country` and `category` during initialization.


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
```

### 3.2. Dynamic initialization

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

### 3.3. Search and enumerable

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
# Loop through `top_stories:sg:*` and `top_stories:sg:*`
TopStoriesCache.where(country: 'sg').each do |list|
  list.key # top_stories:sg:10
  list.smembers # return story ids
  # ...
end
```

### 3.4. Report & Generate documentation

```rb
Sider.report
```

```
TBD
```

### 3.5 Audit keys

```rb
TopStoriesCache.count # Scan and count

TopStoriesCache.all # NOT RECOMMENDED if there are too many keys
```

---

## 4. Data Types

`Sider` provides support for 7 main Redis data types.

### 4.1. `Sider::String`

TBD

### 4.2. `Sider::Hash`

TBD

### 4.3. `Sider::List`

TBD

### 4.4. `Sider::Set`

TBD

### 4.5. `Sider::SortedSet`

TBD

### 4.6. `Sider::Bitmap`

TBD

### 4.7. `Sider::HyperLogLog`

TBD


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

## 6. Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## 7. Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sider. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/sider/blob/master/CODE_OF_CONDUCT.md).


## 8. License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## 9. Code of Conduct

Everyone interacting in the Sider project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/sider/blob/master/CODE_OF_CONDUCT.md).
