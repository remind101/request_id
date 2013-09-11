require 'spec_helper'
require 'securerandom'

def capture
  out = StringIO.new
  $stdout = out
  yield
  return out
ensure
  $stdout = STDOUT
end

describe Sidekiq::Middleware::Client::RequestId do
  let(:middleware) { described_class.new }

  describe '.call' do
    context 'when the worker is an object that responds to `get_sidekiq_options`' do
      let(:worker) { double('worker', to_s: 'Worker') }

      context 'when the worker is configured to log request ids' do
        let(:logger) { double('Logger') }

        before { worker.stub get_sidekiq_options: { 'log_request_id' => true } }
        before { Sidekiq.stub logger: logger }

        it 'logs the request id' do
          request_id = Thread.current[:request_id] = SecureRandom.hex
          logger.should_receive(:info).with(
            "request_id=#{request_id} at=enqueue worker=Worker args=[\"foo\"]"
          )
          expect { |b| middleware.call(worker, { 'args' => ['foo'] }, nil, &b) }.to yield_control
        end
      end

      context 'when the worker is not configured to log request ids' do
        before { worker.stub get_sidekiq_options: {} }

        it 'does not log the request' do
          expect { |b| middleware.call(worker, {}, nil, &b) }.to yield_control
        end
      end
    end

    context 'when the worker is an object that does not respond to `get_sidekiq_options`' do
      let(:worker) { 'Worker' }

      it 'does not log the request' do
        expect { |b| middleware.call(worker, {}, nil, &b) }.to yield_control
      end
    end
  end
end
