require 'spec_helper'
require 'securerandom'

describe RequestId do
  let(:request_id) { SecureRandom.hex }

  describe '.request_id' do
    subject { described_class.request_id }

    context 'when Thread.current[:request_id] is set' do
      before { Thread.current[:request_id] = request_id }
      it { should eq Thread.current[:request_id] }
    end
  end

  describe '.request_id=' do
    it 'sets Thread.current[:request_id]' do
      Thread.current.should_receive(:[]=).with(:request_id, request_id)
      described_class.request_id = request_id
    end
  end

  describe '.with_request_id' do
    before { Thread.current[:request_id] = request_id }

    it 'sets the request_id to the new request_id' do
      described_class.with_request_id('foobar') do
        expect(described_class.request_id).to eq 'foobar'
      end
      expect(described_class.request_id).to eq request_id
    end
  end
end
