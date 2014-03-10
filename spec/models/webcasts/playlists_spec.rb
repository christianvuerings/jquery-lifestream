require "spec_helper"

describe Webcasts::Playlists do

  subject { Webcasts::Playlists.new({:playlist_title => "Biology 1A, 001 - Spring 2012"}) }

  context "normal return of real data", :testext => true do
    it "should return playlist id" do
      result = subject.request_internal
      result[:playlist_id].should == "ECCF8E59B3C769FB01"
    end
  end

  context "on remote server errors" do
    before(:each) {
      stub_request(:any, /#{Regexp.quote(Settings.playlists_proxy.base_url)}.*/).to_return(status: 500)
    }
    after(:each) { WebMock.reset! }
    it "should return the fetch error message" do
      response = subject.get
      response[:error_message].should == "There was a problem fetching the videos."
    end
  end

  context "when json formatting fails" do
    before(:each) {
      stub_request(:any, /#{Regexp.quote(Settings.playlists_proxy.base_url)}.*/).to_return(status: 200, body: "bogus json")
    }
    after(:each) { WebMock.reset! }
    it "should return the fetch error message" do
      response = subject.get
      response[:error_message].should == "There was a problem fetching the videos."
    end
  end

end
