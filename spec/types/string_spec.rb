RSpec.describe Sider::String do
  class MockedString < Sider::String
    key_pattern 'name:{language}:{order}'
    description 'This is mocked string'
  end

  let(:mocked_string) { MockedString.build(language: 'en', order: 10) }

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
end
