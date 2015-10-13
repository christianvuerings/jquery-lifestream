describe CampusSolutions::AddressType do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:addressTypes]).to be
      expect(subject[:feed][:addressTypes][0][:fieldvalue]).to be
      expect(subject[:feed][:addressTypes][0][:descr]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::AddressType.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::AddressType.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
