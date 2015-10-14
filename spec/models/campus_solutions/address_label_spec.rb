describe CampusSolutions::AddressLabel do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    it_behaves_like 'a proxy that properly observes the profile feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:labels]).to be
      expect(subject[:feed][:labels][0][:label]).to be
      expect(subject[:feed][:labels][0][:field]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::AddressLabel.new(fake: true, country: 'ESP') }
    it_should_behave_like 'a proxy that gets data'
    subject { proxy.get }
    it 'should properly camelize the fields' do
      expect(subject[:feed][:labels][0][:label]).to eq 'Street Type'
      expect(subject[:feed][:labels][0][:field]).to eq 'addrField1'
      expect(subject[:feed][:labels][3][:label]).to eq 'Address 1'
      expect(subject[:feed][:labels][3][:field]).to eq 'address1'
      expect(subject[:feed][:labels][9][:label]).to eq 'Door'
      expect(subject[:feed][:labels][9][:field]).to eq 'num2'
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::AddressLabel.new(fake: false, country: 'ESP') }
    it_should_behave_like 'a proxy that gets data'
  end

end
