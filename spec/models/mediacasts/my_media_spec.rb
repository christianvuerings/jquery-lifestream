require "spec_helper"

describe Mediacasts::MyMedia do

  let(:proxy_error_hash) do
    { :proxy_error_message => "Proxy Error" }
  end

  let(:empty_proxy_error_hash) do
    { :proxy_error_message => "" }
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
    { :videos => ['video1', 'video2'] }
  end

  let(:fake_podcast_result) do
    { :podcast => 'podcast link' }
  end

  context "when serving mediacasts" do

    context "when playlist title has a _slash_" do
      it "should decode _slash_ to /" do
        my_media = Mediacasts::MyMedia.new({:playlist_title => "Eve_slash_Wknd Masters in Bus. Adm. 236G, 11A - Fall 2013"})
        expect(my_media.instance_eval {@playlist_title}).to eq "Eve/Wknd Masters in Bus. Adm. 236G, 11A - Fall 2013"
      end
    end

    context "when playlist title has no slash" do
      it "should do nothing to title" do
        title = "Computer Science 61A, 001 - Fall 2013"
        my_media = Mediacasts::MyMedia.new({:playlist_title => title})
        expect(my_media.instance_eval {@playlist_title}).to eq title
      end
    end

    context "when proxy error message is not blank" do
      before { subject.should_receive(:get_playlist).twice.and_return(proxy_error_hash) }
      it "should return the proxy error message" do
        expect(subject.get_media_as_json).to be_an_instance_of Hash
        expect(subject.get_media_as_json[:proxyErrorMessage]).to eq "Proxy Error"
      end
    end

    context "when proxy error message is blank" do
      it "should return mediacasts" do
        subject.should_receive(:get_playlist).and_return(empty_proxy_error_hash)
        subject.should_receive(:get_videos_as_json).and_return(fake_video_result)
        subject.should_receive(:get_podcasts_as_json).and_return(fake_podcast_result)
        result = subject.get_media_as_json
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

end
