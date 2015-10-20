describe HubEdos::Person do

  context 'mock proxy' do
    let(:proxy) { HubEdos::Person.new(fake: true) }
    subject { proxy.get }

    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_should_behave_like 'a simple proxy that returns errors'

    it 'returns data with the expected structure' do
      expect(subject[:feed]['person']).to be
      expect(subject[:feed]['person']['identifiers'][0]['id']).to be
    end

  end
end
