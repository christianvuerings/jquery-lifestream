describe Cal1card::MyCal1card do

  let!(:oski_uid) { '61889' }
  let!(:fake_proxy) { Cal1card::MyCal1card.new(oski_uid, {fake: true}) }
  let!(:real_oski_proxy) { Cal1card::MyCal1card.new(oski_uid, {fake: false}) }
  before do
    Cal1card::MyCal1card.stub(:new).and_return(fake_proxy)
  end
  subject { Cal1card::MyCal1card.new(oski_uid).get_feed }

  it_behaves_like 'a polite HTTP client'

  context 'happy path with fake data' do
    include_context 'Live Updates cache'
    it 'feeds back correct information' do
      expect(subject).to be_truthy
      expect(subject[:cal1cardStatus]).to eq 'OK'
      expect(subject[:debit]).to eq '0.8'
      expect(subject[:mealpoints]).to eq '359.11'
      expect(subject[:mealpointsPlan]).to eq 'Resident Meal Plan Points'
      expect(subject[:statusCode]).to eq 200
    end
  end

  context 'capture a disabled feature flag' do
    include_context 'Live Updates cache'
    before do
      Settings.features.stub(:cal1card).and_return(false)
    end
    it 'respect the disabled feature flag'do
      expect(subject.length).to eq 2
    end
  end

  context 'server errors' do
    include_context 'short-lived Live Updates cache'
    let (:cal1card_uri) { URI.parse(Settings.cal1card_proxy.base_url) }
    before do
      Cal1card::MyCal1card.stub(:new).and_return(real_oski_proxy)
    end
    after(:context) do
      WebMock.reset!
    end

    context 'unreachable remote server (connection errors)' do
      before do
        stub_request(:any, /.*#{cal1card_uri.hostname}.*/).to_raise(Errno::ECONNREFUSED)
      end
      it 'reports an error' do
        expect(subject[:body]).to eq('An error occurred retrieving data for Cal 1 Card. Please try again later.')
        expect(subject[:statusCode]).to eq 503
      end
    end

    context 'error on remote server (5xx errors)' do
      let!(:status) { 506 }
      let!(:uid) { oski_uid }
      include_context 'expecting logs from server errors'
      before do
        stub_request(:any, /.*#{cal1card_uri.hostname}.*/).to_return(status: status)
      end
      it 'reports an error' do
        expect(subject[:body]).to eq('An error occurred retrieving data for Cal 1 Card. Please try again later.')
        expect(subject[:statusCode]).to eq 503
      end
    end
  end

end
