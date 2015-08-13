require 'spec_helper'

describe CampusSolutions::Country do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns JSON fixture data by default' do
      expect(subject[:feed][:countries]).to be
      expect(subject[:feed][:countries][0][:country]).to eq 'BGD'
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Country.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy' do
    let(:proxy) { CampusSolutions::Country.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
