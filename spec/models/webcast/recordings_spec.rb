describe Webcast::Recordings do

  let (:webcast_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/webcast.json" }

  context 'a fake proxy' do
    context 'data organized by ccn' do
      let(:recordings) { Webcast::Recordings.new({:fake => true}).get }
      it 'should return a lot of playlists' do
        expect(recordings[:courses].keys.length).to eq 21
        law_2723 = recordings[:courses]['2008-D-49688']
        expect(law_2723).to_not be_nil
        expect(law_2723[:recordings]).to have(12).items
      end
    end
  end

  context 'a real, non-fake proxy' do
    subject { Webcast::Recordings.new }

    context 'normal return of real data', :testext => true do
      it 'should return a bunch of playlists' do
        result = subject.get
        courses = result[:courses]
        expect(courses).to_not be_nil
        expect(courses.keys.length).to be >= 0
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
        expect(response[:proxy_error_message]).to include('There was a problem')
      end
    end

    context 'when json formatting fails' do
      before(:each) {
        stub_request(:any, /.*#{webcast_uri.hostname}.*/).to_return(status: 200, body: 'bogus json')
      }
      after(:each) { WebMock.reset! }
      it 'should return the fetch error message' do
        response = subject.get
        expect(response[:proxy_error_message]).to include('There was a problem')
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

    context 'course with zero recordings is different than course not scheduled for recordings', :testext => true do
      it 'returns nil recordings attribute when course is scheduled for recordings' do
        result = subject.get
        non_existent = result[:courses]['2015-B-1']
        recordings_planned = result[:courses]['2015-B-58301']
        recordings_exist = result[:courses]['2015-B-56745']
        expect(non_existent).to be_nil
        expect(recordings_planned[:recordings]).to be_nil
        expect(recordings_exist[:recordings]).to have_at_least(10).items
      end
    end
  end

end
