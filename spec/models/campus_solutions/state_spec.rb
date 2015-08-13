require 'spec_helper'

describe CampusSolutions::State do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns JSON fixture data by default' do
      expect(subject[:feed][:states]).to be
      expect(subject[:feed][:states][0][:state]).to eq 'MT'
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::State.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy' do
    let(:proxy) { CampusSolutions::State.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
