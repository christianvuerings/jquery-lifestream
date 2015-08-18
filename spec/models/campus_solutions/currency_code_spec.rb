require 'spec_helper'

describe CampusSolutions::CurrencyCode do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed][:currencyCodes]).to be
      expect(subject[:feed][:currencyCodes][0][:currencyCd]).to eq 'AWG'
      expect(subject[:feed][:currencyCodes][0][:descr]).to eq 'Aruban Guilder'
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::CurrencyCode.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::CurrencyCode.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
