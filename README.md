# RequestId

Middleware for logging heroku request id's. The gem includes:

* Rack middleware, which adds the request\_id to `Thread.current[:request\_id]`
* Sidekiq Client middleware, which adds the request\_id to to the message
  payload.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'request_id', github: 'remind101/request_id'
```

## Usage

Add the rack middleware:

```ruby
use Rack::RequestId
```

Add the sidekiq middleware, if you need it:

```ruby
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::RequestId
  end
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
