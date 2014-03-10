require "spec_helper"

describe MyVideos do

  let(:error_hash) do
    {:error_message => "Error"}
  end

  let(:empty_error_hash) do
    {:error_message => ""}
  end

  context "when serving videos" do

    context "when playlist title has a _slash_" do
      it "should decode _slash_ to /" do
        my_videos = MyVideos.new({:playlist_title => "Eve_slash_Wknd Masters in Bus. Adm. 236G, 11A - Fall 2013"})
        expect(my_videos.instance_eval {@playlist_title}). to eq "Eve/Wknd Masters in Bus. Adm. 236G, 11A - Fall 2013"
      end
    end

    context "when playlist title has no slash" do
      it "should do nothing to title" do
        title = "Computer Science 61A, 001 - Fall 2013"
        my_videos = MyVideos.new({:playlist_title => title})
        expect(my_videos.instance_eval {@playlist_title}). to eq title
      end
    end

    context "when error message is not blank" do
      before { subject.should_receive(:get_playlist).twice.and_return(error_hash) }
      it "should return the error message" do
        expect(subject.get_videos_as_json).to be_an_instance_of Hash
        expect(subject.get_videos_as_json[:error_message]).to eq "Error"
      end
    end

    context "when error message is blank" do
      before { subject.should_receive(:get_playlist).and_return(empty_error_hash) }
      before { subject.should_receive(:get_youtube_videos).and_return(true) }
      it "should return the videos" do
        expect(subject.get_videos_as_json).to be_true
      end
    end

  end

end
