require 'spec_helper'

describe CampusSolutions::NameType do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:nameTypes]).to be
      expect(subject[:feed][:nameTypes][0][:nameTypeDescr]).to eq 'Preferred'
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::NameType.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::NameType.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
