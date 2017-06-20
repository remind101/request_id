# RequestId

This is a gem with a collection of middleware for easily cascading [Heroku request id's](https://devcenter.heroku.com/articles/http-request-id)
Throughout the system. It includes:

* Rack middleware, which adds the request\_id to `Thread.current[:request_id]`.
* Sidekiq Client middleware, which adds the request\_id to the message
  payload.
* Sidekiq Server middleware, which adds the request\_id to
  `Thread.current[:request_id]` from the request\_id in the message payload.
* Faraday middleware, which adds the request\_id as a response header `X-Request-Id`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_id'
```

## Usage

Add the rack middleware:

```ruby
use Rack::RequestId
```

### If you're using Sidekiq

Add the client middleware.

```ruby
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::RequestId
  end
end
```

Add the server middleware.

```ruby
Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::RequestId
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RequestId
  end
end
```

If you're using other Sidekiq middleware that wraps job execution, consider
using Sidekiq's
[`chain.prepend`](http://www.rubydoc.info/github/mperham/sidekiq/Sidekiq%2FMiddleware%2FChain%3Aprepend)
in place of `chain.add` to push the `request_id` middleware to the top of the
stack so it runs before other possibly dependent middleware. For example:

```ruby
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.prepend Sidekiq::Middleware::Client::RequestId
  end
end
```

### If you're using Faraday

Add the middleware.

```ruby
  builder.use Faraday::RequestId

```

### Customization

You can customize each middleware to store the value of any header you like in the same fashion. For instance,
if you wanted to track a `X-Request-Id` header as well as a `X-Session-Id` header, you could do so like this:

```ruby
# Rack
use Rack::RequestId
use Rack::RequestId, key: :request_id, value: -> (env) { env['HTTP_X_SESSION_ID'], response_header: 'X-Session-Id' }

# Sidekiq
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::RequestId
    chain.add Sidekiq::Middleware::Client::RequestId, key: :session_id, value: -> { ::RequestId.get(:session_id) }
  end
end

Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::RequestId
    chain.add Sidekiq::Middleware::Client::RequestId, key: :session_id, value: -> { ::RequestId.get(:session_id) }
  end

  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::RequestId, key: :session_id, value: lambda { |item| item['session_id'] }
  end
end

# Faraday
builder.use Faraday::RequestId, key: :session_id, header: 'X-Session-Id'
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
