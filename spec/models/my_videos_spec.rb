require "spec_helper"

describe MyVideos do

  let(:error_hash) do
    {:error_message => "Error"}
  end

  let(:empty_error_hash) do
    {:error_message => ""}
  end

  context "when serving videos" do

    context "when error message is not blank" do
      before { subject.should_receive(:get_playlist_id).twice.and_return(error_hash) }
      it "should return the error message" do
        expect(subject.get_videos_as_json).to be_an_instance_of Hash
        expect(subject.get_videos_as_json[:error_message]).to eq "Error"
      end
    end

    context "when error message is blank" do
      before { subject.should_receive(:get_playlist_id).and_return(empty_error_hash) }
      before { subject.should_receive(:get_youtube_videos).and_return(true) }
      it "should return the videos" do
        expect(subject.get_videos_as_json).to be_true
      end
    end

  end

end
