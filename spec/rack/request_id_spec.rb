require 'spec_helper'
require 'securerandom'

describe Rack::RequestId do
  let(:app) { double('app', call: [200, {}, ['Body']]) }
  let(:config) { { headers: [ { key: :request_id, value: lambda { |env| env['HTTP_X_REQUEST_ID'] }, response_header: 'X-Request-Id' } ] } }
  let(:middleware) { described_class.new app, config }

  describe '.call' do
    let(:request_id) { SecureRandom.hex }

    it 'stores the request_id in a thread local' do
      expect(Thread.current).to receive(:[]=).with(:request_id, request_id)
      expect(app).to receive(:call)
      expect(Thread.current).to receive(:[]=).with(:request_id, nil)
      middleware.call('HTTP_X_REQUEST_ID' => request_id)
    end

    it 'sets the X-Request-Id header in the response' do
      status, headers, body = middleware.call('HTTP_X_REQUEST_ID' => request_id)
      expect(headers['X-Request-Id']).to eq request_id
    end

    context 'when config.generate == false' do
      before do
        RequestId.configure { |c| c.generate = false }
      end

      after do
        RequestId.configure { |c| c.generate = true }
      end

      it 'does not generate a request id if none is present' do
        status, headers, body = middleware.call({})
        expect(headers['X-Request-Id']).to be_empty
      end
    end

    context 'when config.generate == true' do
      before do
        RequestId.configure { |c| c.generate = true }
      end

      after do
        RequestId.configure { |c| c.generate = false }
      end

      it 'generates a request id if none is present' do
        status, headers, body = middleware.call({})
        expect(headers['X-Request-Id']).to_not be_empty
      end
    end

    context 'when an exception is raised' do
      it 'still sets the request_id back to nil' do
        expect(Thread.current).to receive(:[]=).with(:request_id, request_id)
        expect(app).to receive(:call).and_raise
        expect(Thread.current).to receive(:[]=).with(:request_id, nil)
        expect { middleware.call('HTTP_X_REQUEST_ID' => request_id) }.to raise_error(RuntimeError)
      end
    end
  end

  describe 'custom middleware configuration' do
    let(:config) { { headers: [
      { key: :session_id, value: lambda { |env| env['HTTP_X_SESSION_ID'] }, response_header: 'X-Session-Id' },
      { key: :client_id, value: lambda { |env| env['HTTP_X_CLIENT_ID'] }, response_header: 'X-Client-Id' } ] } }
    let(:session_id) { SecureRandom.hex }
    let(:client_id) { SecureRandom.hex }

    it 'stores the custom id in a thread local' do
      expect(Thread.current).to receive(:[]=).with(:session_id, session_id)
      expect(Thread.current).to receive(:[]=).with(:client_id, client_id)
      expect(app).to receive(:call)
      expect(Thread.current).to receive(:[]=).with(:session_id, nil)
      expect(Thread.current).to receive(:[]=).with(:client_id, nil)
      middleware.call({ 'HTTP_X_SESSION_ID' => session_id, 'HTTP_X_CLIENT_ID' => client_id })
    end

    it 'sets the X-Session-Id and X-Client-Id headers in the response' do
      status, headers, body = middleware.call({ 'HTTP_X_SESSION_ID' => session_id, 'HTTP_X_CLIENT_ID' => client_id})
      expect(headers['X-Session-Id']).to eq session_id
      expect(headers['X-Client-Id']).to eq client_id
    end

    context 'when an exception is raised' do
      it 'still sets the session_id back to nil' do
        expect(Thread.current).to receive(:[]=).with(:session_id, session_id)
        expect(Thread.current).to receive(:[]=).with(:client_id, client_id)
        expect(app).to receive(:call).and_raise
        expect(Thread.current).to receive(:[]=).with(:session_id, nil)
        expect(Thread.current).to receive(:[]=).with(:client_id, nil)
        expect { middleware.call({ 'HTTP_X_SESSION_ID' => session_id, 'HTTP_X_CLIENT_ID' => client_id}) }.to raise_error(RuntimeError)
      end
    end

  end
end
