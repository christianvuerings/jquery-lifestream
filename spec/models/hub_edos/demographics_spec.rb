describe HubEdos::Demographics do

  context 'mock proxy' do
    let(:proxy) { HubEdos::Demographics.new(fake: true, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['ethnicities'][0]['group']['code']).to eq '2'
      expect(subject[:feed]['student']['usaCountry']).to be
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { HubEdos::Demographics.new(fake: false, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['ethnicities'][0]).to be
    end

  end
end
