require "spec_helper"

describe Mediacasts::AllPlaylists do

  let (:playlist_uri) { URI.parse(Settings.playlists_warehouse_proxy.base_url) }

  context 'a fake proxy' do
    subject { Mediacasts::AllPlaylists.new({:fake => true}) }

    context 'a normal return of fake data' do
      it 'should return a lot of playlists' do
        result = subject.get
        expect(result[:courses].keys.length).to eq 321
      end
    end
  end

  context 'a real, nonfake proxy' do
    subject { Mediacasts::AllPlaylists.new }

    context "normal return of real data", :testext => true do
      it "should return a bunch of playlists" do
        result = subject.get
        expect(result[:courses].keys.length).to be >= 0
      end
    end

    context "on remote server errors" do
      before(:each) {
        stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 506)
      }
      after(:each) { WebMock.reset! }
      it "should return the fetch error message" do
        response = subject.get
        expect(response[:proxy_error_message]).to eq "There was a problem fetching the webcasts and podcasts."
      end
    end

    context "when json formatting fails" do
      before(:each) {
        stub_request(:any, /.*#{playlist_uri.hostname}.*/).to_return(status: 200, body: "bogus json")
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
        result = subject.get
        expect(result).to be_an_instance_of Hash
        expect(result).to be_empty
      end
    end
  end
end
