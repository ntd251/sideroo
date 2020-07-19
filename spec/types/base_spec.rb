RSpec.describe Sideroo::Base do
  class BaseCache < Sideroo::Base
    key_pattern 'name:{language}:{order}'
    description 'This is mocked string'
    example 'name:en:1000'
  end

  let(:cache) { BaseCache.new(language: 'en', order: 10) }

  let(:unmatched_keys) do
    [
      'random_key',
      'my_key:fr:10',
      'my_another_key:us:12',
    ]
  end

  let(:matched_keys) do
    [
      'name:en:1',
      'name:fr:10',
    ]
  end

  before do
    matched_keys.each do |key|
      Sideroo.redis_client.set(key, 'john')
    end

    unmatched_keys.each do |key|
      Sideroo.redis_client.set(key, 'john')
    end
  end

  describe '.all' do
    subject { BaseCache.all }

    it 'returns correct objects' do
      output = subject.map(&:key).sort

      expect(output).to eq matched_keys.sort
    end
  end

  describe '.count' do
    subject { BaseCache.count }

    it 'returns the correct count' do
      expect(subject).to eq matched_keys.count
    end
  end

  describe '.flush' do
    subject { MockedString.flush }

    it 'delete all correct keys' do
      expect { subject }
        .to change { BaseCache.count }
        .from(matched_keys.count).to(0)
    end

    it 'does not delete unmatched keys' do
      subject

      unmatched_keys.each do |key|
        redis = Sideroo.redis_client
        expect(redis.exists(key)).to be_truthy
      end
    end
  end
end
