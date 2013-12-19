require "spec_helper"

describe MyPlaylists do

  subject { MyPlaylists.new({:playlist_title => "Biology 1A, 001 - Spring 2012"}) }

  let(:proxy_response) { PlaylistsProxy.new.get }
  let(:data) { subject.convert_to_json(proxy_response) }
  let(:fetch_error_message) { subject.instance_eval {@fetch_error_message} }
  let(:no_videos_error_message) { subject.instance_eval {@no_videos_error_message} }
  let(:error_message) { subject.instance_eval {@my_playlist[:error_message]} }
  let(:playlist_id) { subject.instance_eval {@my_playlist[:playlist_id]} }

  context "when traversing data" do
    it "should return playlist id", :testext => true do
      subject.get_playlist_id(data)
      expect(playlist_id).to eq "ECCF8E59B3C769FB01"
    end
  end

  context "when formatting succeeds" do
    it "should format response to json", :testext => true do
      expect(data["itu_courses"]).not_to be_nil
    end
  end

  context "when formatting fails" do
    before { subject.should_receive(:convert_to_json).and_return(false) }
    before { subject.get_playlists_as_json }

    it "should return the fetch error message" do
      expect(error_message).to eq fetch_error_message
    end

    it "should return an empty playlist id" do
      expect(playlist_id).to eq ""
    end
  end

  context "when response is blank" do
    before { subject.should_receive(:request).and_return(nil) }
    before { subject.get_playlists_as_json }

    it "should return the fetch error message" do
      expect(error_message).to eq fetch_error_message
    end

    it "should return an empty playlist id" do
      expect(playlist_id).to eq ""
    end
  end

end
