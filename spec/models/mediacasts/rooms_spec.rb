describe Mediacasts::Rooms do

  let (:rooms_json_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/rooms.json" }
  let (:term_yr) { 2015 }
  let (:term_cd) { 'D' }

  context 'a fake proxy' do
    subject { Mediacasts::Rooms.new(term_yr, term_cd, {:fake => true}) }

    context 'fake data' do
      it 'should return webcast-enabled rooms' do
        buildings = subject.get
        expect(buildings.length).to eq 26
      end
    end
  end

  context 'a real, non-fake proxy' do
    subject { Mediacasts::Rooms.new(term_yr, term_cd) }

    context 'real data', :testext => true do
      it 'should return at least one building' do
        buildings = subject.get
        expect(buildings.keys.length).to be >= 0
      end
    end

    context 'on remote server errors' do
      let! (:body) { 'An unknown error occurred.' }
      let! (:status) { 506 }
      include_context 'expecting logs from server errors'
      before(:each) {
        stub_request(:any, /.*#{rooms_json_uri.hostname}.*/).to_return(status: status, body: body)
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        buildings = subject.get
        expect(buildings[:proxy_error_message]).to include('There was a problem')
      end
    end

    context 'when json formatting fails' do
      before(:each) {
        stub_request(:any, /.*#{rooms_json_uri.hostname}.*/).to_return(status: 200, body: 'bogus json')
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        buildings = subject.get
        expect(buildings[:proxy_error_message]).to include('There was a problem')
      end
    end

    context 'when webcast feature is disabled' do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it 'should return an empty hash' do
        buildings = subject.get
        expect(buildings).to be_an_instance_of Hash
        expect(buildings).to be_empty
      end
    end
  end

end
