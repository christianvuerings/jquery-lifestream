describe CampusSolutions::DashboardUrl do

  shared_examples 'a proxy that gets data' do
    subject { proxy.get }
    it_should_behave_like 'a simple proxy that returns errors'
    let(:flag) { :show_notifications_archive_link }
    it_behaves_like 'a proxy that observes a feature flag'
    it_behaves_like 'a proxy that got data successfully'
    it 'returns data with the expected structure' do
      expect(subject[:feed][:url]).to be
    end
  end

  context 'mock proxy' do
    let(:proxy) { CampusSolutions::DashboardUrl.new(fake: true) }
    it_should_behave_like 'a proxy that gets data'
    subject { proxy.get }
    it 'should properly camelize the fields' do
      expect(subject[:feed][:url]).to eq('https://bcs-web-dev-03.is.berkeley.edu:8443/psc/bcsdev/EMPLOYEE/HRMS/c/CCI_COMMUNICATION_CENTER_SS.CCI_COMM_CENTER_FL.GBL')
    end
  end

  context 'real proxy', testext: true do
    let(:proxy) { CampusSolutions::DashboardUrl.new(fake: false) }
    it_should_behave_like 'a proxy that gets data'
  end

end
