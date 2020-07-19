RSpec.describe Sideroo::Enumerator do
  let(:record_klass_with_default_regex) do
    Class.new(Sideroo::String) do
      key_pattern 'name:{language}:{order}'
    end
  end

  let(:record_klass_with_custom_regex) do
    Class.new(Sideroo::String) do
      key_pattern 'name:{language}:{order}'
      key_regex /^name\:[^:]+\:[^:]+$/
    end
  end

  let(:record_klass) { record_klass_with_default_regex }

  let(:enumerator) do
    Sideroo::Enumerator.new(
      type_klass: record_klass,
      filters: { language: 'en' },
    )
  end

  before do
    redis = Sideroo.redis_client

    # always counted
    10.times.each do |index|
      redis.set("name:en:#{index}", 'john')
    end

    # counted if using default regex
    3.times.each do |index|
      redis.set("name:en:#{index}:extra", 'john')
    end

    # not counted
    4.times.each do |index|
      redis.set("name:#{index}", 'john')
    end

    # not counted
    5.times.each do |index|
      redis.set("name:fr:#{index}", 'john')
    end
  end

  describe '#each' do
    subject do
      enumerator.each do |item|
        watcher.watch(item)
      end
    end

    let(:watcher) { double('watcher') }

    before do
      allow(watcher).to receive(:watch)
    end

    context 'when using default key_regex' do
      let(:record_klass) { record_klass_with_default_regex }

      it 'received correct number of items' do
        expect(watcher).to receive(:watch).exactly(13).times
        subject
      end
    end

    context 'when using custom key_regex' do
      let(:record_klass) { record_klass_with_custom_regex }

      it 'received correct number of items' do
        expect(watcher).to receive(:watch).exactly(10).times
        subject
      end
    end
  end

  describe '#count' do
    subject do
      enumerator.count
    end

    it 'returns correct number of items' do
      expect(subject).to eq 13
    end
  end

  describe '#map' do
    subject do
      enumerator.map { '' }
    end

    it 'returns correct number of items' do
      expect(subject.count).to eq 13
    end
  end
end
