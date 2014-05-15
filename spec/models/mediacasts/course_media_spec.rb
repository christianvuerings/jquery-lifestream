require "spec_helper"

describe Mediacasts::CourseMedia do

  let(:proxy_error_hash) do
    {:proxy_error_message => "Proxy Error"}
  end

  let(:empty_proxy_error_hash) do
    {:proxy_error_message => ""}
  end

  let(:errors) do
    {
      :video_error_message => "There are no webcasts available.",
      :podcast_error_message => "There are no podcasts available."
    }
  end

  let(:playlist_id) { 'abcdef' }
  let(:podcast_id) { '12345' }

  let(:fake_playlist) do
    {
      :playlist_id => playlist_id,
      :podcast_id => podcast_id
    }
  end

  let(:fake_playlist_no_videos) do
    {
      :podcast_id => podcast_id,
      :video_error_message => errors[:video_error_message]
    }
  end

  let(:fake_playlist_no_podcasts) do
    {
      :playlist_id => playlist_id,
      :podcast_error_message => errors[:podcast_error_message]
    }
  end

  let(:fake_video_result) do
    {:videos => ['video1', 'video2']}
  end

  let(:fake_podcast_result) do
    {:podcast => 'podcast link'}
  end

  context "when serving mediacasts" do

    subject { Mediacasts::CourseMedia.new(2008, 'D', 'LAW', '2723') }

    context "when proxy error message is not blank" do
      before { subject.should_receive(:get_playlist).twice.and_return(proxy_error_hash) }
      it "should return the proxy error message" do
        expect(subject.get_feed).to be_an_instance_of Hash
        expect(subject.get_feed[:proxyErrorMessage]).to eq "Proxy Error"
      end
    end

    context "when proxy error message is blank" do
      it "should return mediacasts" do
        subject.should_receive(:get_playlist).and_return(empty_proxy_error_hash)
        subject.should_receive(:get_videos_as_json).and_return(fake_video_result)
        subject.should_receive(:get_podcasts_as_json).and_return(fake_podcast_result)
        result = subject.get_feed
        expect(result).to be_an_instance_of Hash
        expect(result).to eq fake_video_result.merge(fake_podcast_result)
      end
    end

    context "when podcasts are disabled" do
      before { Settings.features.podcasts = false }
      after { Settings.features.podcasts = true }
      it "should return empty hash" do
        result = subject.get_podcasts_as_json(fake_playlist)
        expect(result).to be_an_instance_of Hash
        expect(result).to be_empty
      end
    end

    context "when podcasts are present" do
      it "should format the itunes url" do
        result = subject.get_podcasts_as_json(fake_playlist)
        expect(result).to be_an_instance_of Hash
        expect(result[:podcast]).to eq 'https://itunes.apple.com/us/itunes-u/id12345'
      end
    end

    context "when podcasts are not present" do
      it "should return podcast error hash" do
        result = subject.get_podcasts_as_json(fake_playlist_no_podcasts)
        expect(result).to be_an_instance_of Hash
        expect(result[:podcastErrorMessage]).to eq errors[:podcast_error_message]
      end
    end

    context "when videos are disabled" do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it "should return empty hash" do
        result = subject.get_videos_as_json(fake_playlist)
        expect(result).to be_an_instance_of Hash
        expect(result).to be_empty
      end
    end

    context "when videos are present" do
      before { subject.should_receive(:get_youtube_videos).and_return(fake_video_result) }
      it "should return youtube videos" do
        result = subject.get_videos_as_json(fake_playlist)
        expect(result).to be_an_instance_of Hash
        expect(result).to eq fake_video_result
      end
    end

    context "when videos are not present" do
      it "should return video error hash" do
        result = subject.get_videos_as_json(fake_playlist_no_videos)
        expect(result).to be_an_instance_of Hash
        expect(result[:videoErrorMessage]).to eq errors[:video_error_message]
      end
    end

  end

  context 'retrieving the playlist id for a course' do
    context 'with a fake playlists proxy' do
      subject { Mediacasts::CourseMedia.new(2008, 'D', 'LAW', '2723') }

      before do
        allow(Mediacasts::AllPlaylists).to receive(:new).and_return(Mediacasts::AllPlaylists.new({fake: true}))
      end

      context 'a normal return of fake data' do
        it 'should return a specific playlist id that we know about' do
          result = subject.get_playlist
          expect(result[:playlist_id]).to eq "EC8DA9DAD111EAAD28"
        end
      end
    end

    context 'with a real, nonfake playlists proxy' do
      let (:playlist_uri) { URI.parse(Settings.playlists_warehouse_proxy.base_url) }
      subject { Mediacasts::CourseMedia.new(2012, 'B', 'BIOLOGY', '1A') }

      context "normal return of real data", :testext => true do
        it "should return playlist id" do
          result = subject.get_playlist
          expect(result[:playlist_id]).to eq "ECCF8E59B3C769FB01"
          expect(result[:podcast_id]).to eq "496300137"
        end
      end

      context "on remote server errors" do
        before(:each) {
          stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 506)
        }
        after(:each) { WebMock.reset! }
        it "should return the fetch error message" do
          response = subject.get_playlist
          expect(response[:proxy_error_message]).to eq "There was a problem fetching the webcasts and podcasts."
        end
      end

      context "when json formatting fails" do
        before(:each) {
          stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 200, body: "bogus json")
        }
        after(:each) { WebMock.reset! }
        it "should return the fetch error message" do
          response = subject.get_playlist
          expect(response[:proxy_error_message]).to eq "There was a problem fetching the webcasts and podcasts."
        end
      end

      context "when videos and podcasts are disabled" do
        before { Settings.features.podcasts = false }
        before { Settings.features.videos = false }
        after { Settings.features.podcasts = true }
        after { Settings.features.videos = true }
        it "should return an empty hash" do
          result = subject.get_playlist
          expect(result).to be_an_instance_of Hash
          expect(result).to be_empty
        end
      end
    end
  end
end
