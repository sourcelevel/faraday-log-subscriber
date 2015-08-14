# Faraday Log Subscriber

A `ActiveSupport::LogSubscriber` to log HTTP requests made by a [Faraday](https://github.com/lostisland/faraday) client instance.

## Installation

Add it to your Gemfile:

```ruby
gem 'faraday-log-subscriber'
```

## Usage

You have to use the `:instrumentation` middleware from [`faraday_middleware`](https://github.com/lostisland/faraday_middleware) to
instrument your requests.

```ruby
client = Faraday.new('https://api.github.com') do |builder|
  builder.use :instrumentation
  builder.adapter :net_http
end

client.get('repos/rails/rails')
# 'Faraday GET [200] (1026.9ms) https://api.github.com/repos/rails/rails'
```

### `faraday-http-cache` integration

If you use the [`faraday-http-cache`](https://github.com/plataformatec/faraday-http-cache) gem, an extra line will be logged regarding
the cache status of the requested URL:


```ruby
client = Faraday.new('https://api.github.com') do |builder|
  builder.use :instrumentation
  builder.use :http_cache, instrumenter: ActiveSupport::Notifications
  builder.adapter :net_http
end

client.get('repos/rails/rails')
client.get('repos/rails/rails')
# Faraday HTTP Cache [fresh] https://api.github.com/repos/rails/rails
# Faraday GET [200] (1.7ms) https://api.github.com/repos/rails/rails
```

## License

Copyright (c) 2015 Plataformatec. See LICENSE file.
