require "spec_helper"
require "json"

describe Youtube do

  it "should get real youtube video data", :textext => true do
    proxy = Youtube.new({:playlist_id => "ECCF8E59B3C769FB01"})
    proxy_response = proxy.request_internal
    proxy_response[:videos][0][:title].should == "Biology 1A - Lecture 36:Circulatory system-cell types and fu"
  end

  it "should filter videos properly", :testext => true do
    proxy = Youtube.new({:playlist_id => "-XXv-cvA_iCIEwJhyDVdyLMCiimv6Tup"})
    proxy_response = proxy.request_internal
    title = "Computer Science 61A - Lecture 40"
    link = "https://www.youtube.com/embed/ggW_KVJQkRE?version=3&f=playlists&app=youtube_gdata&showinfo=0&theme=light&modestbranding=1"

    proxy_response[:videos][0][:title].should == title
    proxy_response[:videos][0][:link].should == link
  end

  context "proper caching behavior", :textext => true do
    before { Rails.cache.should_receive(:write) }
    it "should get and cache json on a successful request" do # , :testext => true do
      proxy = Youtube.new({:playlist_id => "-XXv-cvA_iCIEwJhyDVdyLMCiimv6Tup"})
      json_response = proxy.get
      json_response.should_not be_nil
    end
  end

  context "proper caching behavior when remote site has errors" do
    before(:each) {
      Rails.cache.should_not_receive(:write)
      stub_request(:any, /#{Regexp.quote(Settings.youtube_proxy.base_url)}.*/).to_return(status: 500)
    }
    after(:each) { WebMock.reset! }
    it "should return a response but not cache anything on a failed request" do
      proxy = Youtube.new({:playlist_id => "-XXv-cvA_iCIEwJhyDVdyLMCiimv6Tup"})
      json_response = proxy.get
      json_response.should_not be_nil
    end
  end

end
