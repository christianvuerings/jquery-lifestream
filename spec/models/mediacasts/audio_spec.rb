require "spec_helper"
require "json"

describe Mediacasts::Audio do

  context "real data", :textext => true do

    let (:audio_base_url) { URI.parse(Settings.audio_proxy.base_url) }
    let (:rss_url) { "#{audio_base_url}/media/common/courses/spring_2014/rss/english_117s_001_audio.rss"; }
    let (:proxy) { Mediacasts::Audio.new({:audio_rss => rss_url}) }

    it "should get real audio data" do
      proxy_response = proxy.get
      expect(proxy_response[:audio].count).to eq 26
    end

    it "should get good playUrls" do
      proxy_response = proxy.get
      play_url = "#{audio_base_url}/media/common/courses/spring_2014/media/english_117s_001/340a8274-480e-4bf8-811b-b418af78658b_audio.m4a"
      expect(proxy_response[:audio][0][:playUrl]).to eq play_url
    end

    it "should get correct dates" do
      proxy_response = proxy.get
      expect(proxy_response[:audio][0][:date]).to be_an_instance_of Hash
      expect(proxy_response[:audio][0][:date][:epoch]).to eq 1390336620
    end

    context "on remote server errors" do
      before(:each) {
        stub_request(:any, rss_url).to_return(status: 506)
      }
      it "should return a 500 status code" do
        proxy_response = proxy.get
        expect(proxy_response[:statusCode]).to eq 500
      end
    end

    context "when xml formatting fails" do
      before(:each) {
        stub_request(:any, rss_url).to_return(status: 200, body: "bogus xml")
      }
      it "should return a 503 status code" do
        proxy_response = proxy.get
        expect(proxy_response[:statusCode]).to eq 503
      end
    end

    context "on connection errors" do
      before(:each) {
        stub_request(:any, /.#{audio_base_url.hostname}./).to_raise(Errno::ECONNREFUSED)
      }

      it "should return a 503 status code" do
        proxy_response = proxy.get
        expect(proxy_response[:statusCode]).to eq 503
      end
    end
  end

  context "empty RSS feed" do
    let (:proxy) { Mediacasts::Audio.new({:audio_rss => ""}) }

    it "should return an empty audio array" do
      proxy_response = proxy.get
      expect(proxy_response[:audio].count).to eq 0
    end
  end

end
