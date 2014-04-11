require "spec_helper"

describe Mediacasts::Playlists do

  subject { Mediacasts::Playlists.new({:playlist_title => "Biology 1A, 001 - Spring 2012"}) }

  context "normal return of real data", :testext => true do
    it "should return playlist id" do
      result = subject.request_internal
      expect(result[:playlist_id]).to eq "ECCF8E59B3C769FB01"
      expect(result[:podcast_id]).to eq "496300137"
    end
  end

  context "on remote server errors" do
    before(:each) {
      stub_request(:any, /#{Regexp.quote(Settings.playlists_proxy.base_url)}.*/).to_return(status: 500)
    }
    after(:each) { WebMock.reset! }
    it "should return the fetch error message" do
      response = subject.get
      expect(response[:proxy_error_message]).to eq "There was a problem fetching the webcasts and podcasts."
    end
  end

  context "when json formatting fails" do
    before(:each) {
      stub_request(:any, /#{Regexp.quote(Settings.playlists_proxy.base_url)}.*/).to_return(status: 200, body: "bogus json")
    }
    after(:each) { WebMock.reset! }
    it "should return the fetch error message" do
      response = subject.get
      expect(response[:proxy_error_message]).to eq "There was a problem fetching the webcasts and podcasts."
    end
  end

  context "when videos and podcasts are disabled" do
    before { Settings.features.podcasts = false }
    before { Settings.features.videos = false }
    after { Settings.features.podcasts = true }
    after { Settings.features.videos = true }
    it "should return an empty hash" do
      result = subject.request_internal
      expect(result).to be_an_instance_of Hash
      expect(result).to be_empty
    end
  end

end
