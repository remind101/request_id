require 'spec_helper'
require 'faraday/request_id'

describe Faraday::RequestId do
  let(:app) { double('app', call: nil) }
  let(:middleware) { described_class.new(app) }

  describe '.call' do
    context 'when a request_id is set' do
      before do
        RequestId.stub(get: SecureRandom.hex)
      end

      it 'adds the X-Request-Id header' do
        env = { request_headers: {} }
        middleware.call(env)
        expect(env[:request_headers]['X-Request-Id']).to eq RequestId.request_id
      end
    end

    context 'when no request_id is set' do
      before do
        RequestId.stub(get: nil)
      end

      it 'does not add the X-Request-Id header' do
        env = { request_headers: {} }
        middleware.call(env)
        expect(env[:request_headers]).to_not have_key 'X-Request-Id'
      end
    end

    context 'when a request_id is already set in request headers' do
      let(:request_id) { SecureRandom.hex }

      it 'uses the request id from the env hash' do
        env = { request_headers: { 'X-Request-Id' => request_id } }
        middleware.call(env)
        expect(env[:request_headers]['X-Request-Id']).to eq request_id
      end
    end
  end
end
