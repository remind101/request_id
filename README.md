# RequestId

This is a gem with a collection of middleware for easily cascading [Heroku request id's](https://devcenter.heroku.com/articles/http-request-id)
Throughout the system. It includes:

* Rack middleware, which adds the request\_id to `Thread.current[:request\_id]`
* Sidekiq Client middleware, which adds the request\_id to the message
  payload.
* Sidekiq Server middleware, which adds the request\_id to
  `Thread.current[:request_id]` from the request\_id in the message payload.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_id'
```

## Usage

Add the rack middleware:

```ruby
# If no options are passed this is the default
use Rack::RequestId, key: :request_id, value: -> (env) { env['HTTP_X_REQUEST_ID'], response_header: 'X-Request-Id' }
```

### If you're using Sidekiq

Add the client middleware.

```ruby
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    # If no options are passed this is the default
    chain.add Sidekiq::Middleware::Client::RequestId, key: :request_id, value: -> { ::RequestId.request_id }
  end
end
```

Add the server middleware.

```ruby
Sidekiq.configure_server do |config|
  config.client_middleware do |chain|
    # If no options are passed this is the default
    chain.add Sidekiq::Middleware::Client::RequestId, key: :request_id, value: -> { ::RequestId.request_id }
  end

  config.server_middleware do |chain|
    chain.remove Sidekiq::Middleware::Server::Logging
    # If no options are passed this is the default
    chain.add Sidekiq::Middleware::Client::RequestId, key: :request_id, value: -> { ::RequestId.request_id }
  end
end
```

### If you're using Faraday

Add the middleware.

```ruby
  # If no options are passed this is the default
  builder.use Faraday::RequestId, key: :request_id, header: 'X-Request-Id'

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
