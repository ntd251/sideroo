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

  describe '.dimensions' do
    subject { MockedString.dimensions }

    it 'returns the correct dimensions' do
      expect(subject).to eq ['language', 'order']
    end
  end

  describe 'dimensions as attr_accessor' do
    it 'can read dimensions' do
      expect(cache.language).to eq 'en'
      expect(cache.order).to eq 10
    end

    it 'can set dimensions' do
      expect { cache.language = 'ja' }
        .to change { cache.language }
        .from('en')
        .to('ja')

      expect { cache.order = 20 }
        .to change { cache.order }
        .from(10)
        .to(20)
    end
  end

  describe '.example' do
    describe 'key regex validation' do
      context 'when example does not match default key regex' do
        it 'raises error' do
          expect {
            class InvalidExampleDefaultKlass < Sideroo::Base
              key_pattern 'name:{language}:{order}'
              example 'my_name:en:1000'
            end
          }.to raise_error(Sideroo::InvalidExample)
        end
      end

      context 'when example does not match default key regex' do
        it 'raises error' do
          expect {
            class InvalidExampleCustomKlass < Sideroo::Base
              key_pattern 'name:{language}:{order}'
              key_regex /^name\:(\w+)\:(\d+)$/
              example 'name:en:1000:edge_case'
            end
          }.to raise_error(Sideroo::InvalidExample)
        end
      end

      context 'when example is defined before custom regex' do
        it 'raises error' do
          expect {
            class ExampleOrderKlass < Sideroo::Base
              key_pattern 'name:{language}:{order}'
              example 'name:en:1000:edge_case'
              key_regex /^name\:(\w+)\:(\d+)$/
            end
          }.to raise_error(Sideroo::OutOfOrderConfig)
        end
      end
    end
  end
end
