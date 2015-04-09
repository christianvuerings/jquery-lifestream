describe Mediacasts::AllPlaylists do

  let (:webcast_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/webcast.json" }

  context 'a fake proxy' do
    subject { Mediacasts::AllPlaylists.new({:fake => true}) }

    context 'a normal return of fake data' do
      it 'should return a lot of playlists' do
        result = subject.get
        expect(result[:courses].keys.length).to eq 17
      end
    end
  end

  context 'a real, non-fake proxy' do
    subject { Mediacasts::AllPlaylists.new }

    context 'normal return of real data', :testext => true do
      it 'should return a bunch of playlists' do
        result = subject.get
        expect(result[:courses].keys.length).to be >= 0
      end
    end

    context 'on remote server errors' do
      let! (:body) { 'An unknown error occurred.' }
      let! (:status) { 506 }
      include_context 'expecting logs from server errors'
      before(:each) {
        stub_request(:any, /.*#{webcast_uri.hostname}.*/).to_return(status: status, body: body)
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        response = subject.get
        expect(response[:proxy_error_message]).to eq 'There was a problem fetching the webcasts.'
      end
    end

    context 'when json formatting fails' do
      before(:each) {
        stub_request(:any, /.*#{webcast_uri.hostname}.*/).to_return(status: 200, body: 'bogus json')
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        response = subject.get
        expect(response[:proxy_error_message]).to eq 'There was a problem fetching the webcasts.'
      end
    end

    context 'when videos are disabled' do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it 'should return an empty hash' do
        result = subject.get
        expect(result).to be_an_instance_of Hash
        expect(result).to be_empty
      end
    end
  end
end
