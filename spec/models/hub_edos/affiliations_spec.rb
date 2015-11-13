describe HubEdos::Affiliations do

  context 'mock proxy' do
    let(:proxy) { HubEdos::Affiliations.new(fake: true, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['affiliations'].length).to eq 1
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { HubEdos::Affiliations.new(fake: false, user_id: '61889') }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['student']).to be
      expect(subject[:feed]['student']['affiliations']).to be
    end

  end
end
