require 'spec_helper'
require 'securerandom'

describe Sidekiq::Middleware::Server::RequestId do
  let(:logger) { double('Logger', info: nil) }
  let(:middleware) { described_class.new }

  describe '.call' do
    let(:worker) { double('worker', to_s: 'Worker') }

    context 'when the worker is configured to log request ids' do
      let(:request_id) { SecureRandom.hex }
      let(:item) { { 'args' => ['foo'], 'log_request_id' => true, 'request_id' => request_id } }

      before { Sidekiq.stub logger: logger }

      it 'sets a thread local to the request id' do
        Thread.current.should_receive(:[]=).with(:request_id, request_id)
        Thread.current.should_receive(:[]=).with(:request_id, nil)
        expect { |b| middleware.call(worker, item, nil, &b) }.to yield_control
      end

      it 'logs the request id' do
        logger.should_receive(:info).with(
          "request_id=#{request_id} at=start worker=Worker args=[\"foo\"]"
        )
        expect { |b| middleware.call(worker, item, nil, &b) }.to yield_control
      end
    end

    context 'when the worker is not configured to log request ids' do
      it 'does not log the request' do
        expect { |b| middleware.call(worker, {}, nil, &b) }.to yield_control
      end
    end

    context 'when an error is raised' do
      it 'ensures that the thread local is set to nil, and raises the error' do
        Thread.current.should_receive(:[]=).with(:request_id, nil).twice
        expect { middleware.call(worker, {}, nil) { raise } }.to raise_error
      end
    end
  end
end
