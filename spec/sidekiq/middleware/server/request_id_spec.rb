require 'spec_helper'
require 'securerandom'

describe Sidekiq::Middleware::Server::RequestId do
  let(:logger) { double('Logger', info: nil) }
  let(:middleware) { described_class.new }

  before { Sidekiq.stub logger: logger }

  describe '#call' do
    let(:worker) { double('worker') }

    before { worker.stub_chain :class, to_s: 'Worker' }

    context 'when the worker is configured to log request ids' do
      let(:request_id) { SecureRandom.hex }
      let(:job_id) { SecureRandom.hex }
      let(:item) { { 'jid' => job_id, 'args' => ['foo'], 'log_request_id' => true, 'request_id' => request_id } }

      it 'sets a thread local to the request id' do
        Thread.current.should_receive(:[]=).with(:request_id, request_id)
        Thread.current.should_receive(:[]=).with(:request_id, nil)
        expect { |b| middleware.call(worker, item, nil, &b) }.to yield_control
      end

      it 'logs the request id' do
        Sidekiq::Logging.should_receive(:with_context)
          .with("request_id=#{request_id} worker=Worker jid=#{job_id} args=[\"foo\"]")
          .and_yield
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
