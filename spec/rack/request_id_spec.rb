require 'spec_helper'
require 'securerandom'

describe Rack::RequestId do
  let(:app) { double('app', call: [200, {}, ['Body']]) }
  let(:middleware) { described_class.new app }

  describe '.call' do
    let(:request_id) { SecureRandom.hex }

    it 'stores the request_id in a thread local' do
      Thread.current.should_receive(:[]=).with(:request_id, request_id)
      app.should_receive(:call)
      Thread.current.should_receive(:[]=).with(:request_id, nil)
      middleware.call('HTTP_HEROKU_REQUEST_ID' => request_id)
    end

    it 'sets the X-Request-Id header in the response' do
      status, headers, body = middleware.call('HTTP_HEROKU_REQUEST_ID' => request_id)
      expect(headers['X-Request-Id']).to eq request_id
    end

    context 'when an exception is raised' do
      it 'still sets the request_id back to nil' do
        Thread.current.should_receive(:[]=).with(:request_id, request_id)
        app.should_receive(:call).and_raise
        Thread.current.should_receive(:[]=).with(:request_id, nil)
        expect { middleware.call('HTTP_HEROKU_REQUEST_ID' => request_id) }.to raise_error
      end
    end
  end
end
