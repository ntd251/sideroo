RSpec.describe Sideroo::String do
  class MockedString < Sideroo::String
    key_pattern 'name:{language}:{order}'
    description 'This is mocked string'
  end

  let(:mocked_string) { MockedString.new(language: 'en', order: 10) }

  describe '#get' do
    subject { mocked_string.get }

    it 'performs get on redis' do
      expect { subject }.not_to raise_error
    end
  end

  describe '#set' do
    subject { mocked_string.set('jolie') }

    it do
      expect { subject }.not_to raise_error
    end
  end

  describe '.all' do
    subject { MockedString.all }

    before do
      matched_keys = [
        'name:en:1',
        'name:fr:10',
      ]

      matched_keys.each do |key|
        Sideroo.redis_client.set(key, 'john')
      end

      unmatched_keys = [
        'random_key',
        'my_key:fr:10',
      ]

      unmatched_keys.each do |key|
        Sideroo.redis_client.set(key, 'john')
      end
    end

    it 'returns correct objects' do
      output = subject.map(&:key).sort

      expect(output).to eq [
        'name:en:1',
        'name:fr:10'
      ]
    end
  end
end
