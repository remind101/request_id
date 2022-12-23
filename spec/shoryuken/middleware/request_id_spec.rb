# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

describe Shoryuken::Middleware::RequestId do
  let(:middleware) { described_class.new }

  describe '#call' do
    let(:worker) { double('worker') }
    let(:queue) { double('queue') }
    let(:message_attributes) { {} }
    let(:sqs_msg) { double('sqs_msg', message_attributes: message_attributes) }
    let(:body) { double('body') }

    context 'when the worker is configured to log request ids' do
      let(:request_id) { SecureRandom.hex }
      let(:message_attributes) { { 'request_id' => request_id } }

      it 'sets a thread local to the request id' do
        expect(Thread.current).to receive(:[]=).with(:request_id, request_id)
        expect(Thread.current).to receive(:[]=).with(:request_id, nil)
        expect { |b| middleware.call(worker, queue, sqs_msg, body, &b) }.to yield_control
      end
    end

    context 'when the worker is not configured to log request ids' do
      it 'does not log the request' do
        expect { |b| middleware.call(worker, queue, sqs_msg, body, &b) }.to yield_control
      end
    end

    context 'when an error is raised' do
      it 'ensures that the thread local is set to nil, and raises the error' do
        expect(Thread.current).to receive(:[]=).with(:request_id, nil).twice
        expect { middleware.call(worker, queue, sqs_msg, body) { raise } }.to raise_error(RuntimeError)
      end
    end
  end
end
