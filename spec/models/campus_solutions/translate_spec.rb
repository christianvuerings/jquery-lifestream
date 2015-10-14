describe CampusSolutions::Translate do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'

    it 'returns data with the expected structure' do
      expect(subject[:feed][:xlatvalues]).to be
      expect(subject[:feed][:xlatvalues][:values][0][:fieldvalue]).to be
      expect(subject[:feed][:xlatvalues][:values][0][:xlatlongname]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::Translate.new(fake: true, field_name: 'PHONE_TYPE') }
    it_should_behave_like 'a proxy that gets data'
    subject { proxy.get }
    it 'returns specific mock data' do
      expect(subject[:feed][:xlatvalues][:values][0][:fieldvalue]).to eq 'CELL'
      expect(subject[:feed][:xlatvalues][:values][0][:xlatlongname]).to eq 'Mobile'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::Translate.new(fake: false, field_name: 'PHONE_TYPE') }
    it_should_behave_like 'a proxy that gets data'
  end

end
