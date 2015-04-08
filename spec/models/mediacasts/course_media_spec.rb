describe Mediacasts::CourseMedia do

  let(:proxy_error_hash) do
    {:proxy_error_message => 'Proxy Error'}
  end

  let(:empty_proxy_error_hash) do
    {:proxy_error_message => ''}
  end

  let(:itunes_video_id) { '12345' }
  let(:fake_itunes_no_audio) do
    {
      :itunes_audio => nil,
      :itunes_video => itunes_video_id
    }
  end

  let(:fake_recordings) do
    [
      {
        :lecture => 'Lecture 1: Massachusetts v. EPA and its Aftermath',
        :youTubeId => 'BmGjzCoTjMM',
        :recordingStartUTC => '2009-09-03T15:33:00-07:00'
      },
      {
        :lecture => 'Lecture 2: The Economics of Climate Change',
        :youTubeId => 'CrSfIoRDLL8',
        :recordingStartUTC => '2009-09-05T15:33:00-07:00'
      },
      {
        :lecture => 'Lecture 3: Insurance',
        :youTubeId => 'IdJke1w0JC8',
        :recordingStartUTC => '2009-09-07T15:33:00-07:00'
      },
      {
        :lecture => 'Lecture 4: Financing Adaptation',
        :youTubeId => 'JyEsim_d64Q',
        :recordingStartUTC => '2009-09-10T15:33:00-07:00'
      }
    ]
  end

  let(:fake_playlist) do
    {
      :recordings => fake_recordings,
      :audio_only => false
    }
  end

  let(:fake_playlist_audio_only) do
    {
      :recordings => fake_recordings,
      :audio_only => true
    }
  end

  let(:fake_playlist_no_videos) do
    {
      :recordings => [],
      :audio_only => false
    }
  end

  let(:fake_video_result) do
    {
      :videos => fake_recordings.reverse
    }
  end

  context 'when serving mediacasts' do

    subject { Mediacasts::CourseMedia.new(2008, 'D', 'LAW', '2723') }

    context 'when proxy error message is not blank' do
      before { subject.should_receive(:get_playlist).twice.and_return proxy_error_hash }
      it 'should return the proxy error message' do
        expect(subject.get_feed).to be_an_instance_of Hash
        expect(subject.get_feed[:proxyErrorMessage]).to eq 'Proxy Error'
      end
    end

    context 'when proxy error message is blank' do
      it 'should return mediacasts' do
        subject.should_receive(:get_playlist).and_return empty_proxy_error_hash
        subject.should_receive(:get_videos_as_json).and_return fake_video_result
        result = subject.get_feed
        expect(result).to be_an_instance_of Hash
      end
    end

    context 'when videos are disabled' do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it 'should return empty array' do
        result = subject.get_videos_as_json fake_playlist
        expect(result).to be_an_instance_of Hash
        expect(result[:videos]).to be_empty
      end
    end

    context 'when videos are present' do
      it 'should return youtube videos' do
        result = subject.get_videos_as_json fake_playlist
        expect(result).to be_an_instance_of Hash
        expect(result).to eq fake_video_result
      end
    end

    context 'when videos are not present' do
      it 'should return an empty array' do
        result = subject.get_videos_as_json fake_playlist_no_videos
        expect(result).to be_an_instance_of Hash
        expect(result[:videos]).to eq []
      end
    end

    context 'when audio_only is true' do
      it 'should return an empty response when audio_only is true' do
        result = subject.get_videos_as_json fake_playlist_audio_only
        expect(result).to be_an_instance_of Hash
        expect(result[:videos]).to eq []
      end
    end

    context 'when iTunes audio is nil' do
      it 'should return an iTunes audio nil response' do
        result = subject.get_itunes_as_json fake_itunes_no_audio
        expect(result).to be_an_instance_of Hash
        expect(result[:itunes][:audio]).to eq nil
      end
    end

    context 'when iTunes video is present' do
      it 'should return an iTunes audio nil response' do
        result = subject.get_itunes_as_json fake_itunes_no_audio
        expect(result).to be_an_instance_of Hash
        expect(result[:itunes][:video]).to eq "https://itunes.apple.com/us/itunes-u/id#{itunes_video_id}"
      end
    end

    context 'when course title has a _slash_' do
      it 'should decode _slash_ to /' do
        subject = Mediacasts::CourseMedia.new(2014, 'D', 'MALAY_slash_I', '1A')
        expect(subject.instance_eval {@id}).to eq '2014-D-MALAY/I-1A'
      end
    end

    context 'when course title has no _slash_' do
      it 'should do nothing to title' do
        subject = Mediacasts::CourseMedia.new(2014, 'D', 'COMPSCI', '61A')
        expect(subject.instance_eval {@id}).to eq '2014-D-COMPSCI-61A'
      end
    end

  end

  context 'retrieving the YouTube id for a course' do
    context 'with a fake playlists proxy' do
      subject { Mediacasts::CourseMedia.new(2008, 'D', 'LAW', '2723') }

      before do
        allow(Mediacasts::AllPlaylists).to receive(:new).and_return Mediacasts::AllPlaylists.new({fake: true})
      end

      context 'a normal return of fake data' do
        it 'should return a specific youtube id that we know about' do
          result = subject.get_playlist
          expect(result[:recordings]).to be_an_instance_of Array
          expect(result[:recordings]).to have(12).item
          expect(result[:recordings][0]['youTubeId']).to eq 't3_7rmSe80c'
        end
      end
    end

    context 'with a real, non-fake playlists proxy' do
      let (:playlist_uri) { URI.parse Settings.webcast_proxy.base_url }
      subject { Mediacasts::CourseMedia.new(2014, 'B', 'CHEM', '1AL') }

      context 'normal return of real data', :testext => true do
        it 'should return correct recordings' do
          result = subject.get_playlist
          expect(result[:recordings]).to be_an_instance_of Array
          expect(result[:recordings].size).to eq 14
          recording = result[:recordings][0]
          expect(recording).to be_an_instance_of Hash
          expect(recording['youTubeId']).to eq 'VvOGnqMCbKE'
          expect(recording['lecture']).to eq '2014-01-24: Introduction, safety, observations and notebook skills, How the nose knows'
          expect(recording['recordingStartUTC']).to eq '2014-01-24T00:00:00-08:00'
          # audioOnly
        end
      end

      context 'on remote server errors' do
        before(:each) {
          stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 506)
        }
        after(:each) { WebMock.reset! }
        it 'should return the fetch error message' do
          response = subject.get_playlist
          expect(response[:proxy_error_message]).to eq 'There was a problem fetching the webcasts.'
        end
      end

      context 'when json formatting fails' do
        before(:each) {
          stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 200, body: 'bogus json')
        }
        after(:each) { WebMock.reset! }
        it 'should return the fetch error message' do
          response = subject.get_playlist
          expect(response[:proxy_error_message]).to eq 'There was a problem fetching the webcasts.'
        end
      end

      context 'when videos are disabled' do
        before { Settings.features.videos = false }
        after { Settings.features.videos = true }
        it 'should return an empty hash' do
          result = subject.get_playlist
          expect(result).to be_an_instance_of Hash
          expect(result).to be_empty
        end
      end
    end
  end
end
