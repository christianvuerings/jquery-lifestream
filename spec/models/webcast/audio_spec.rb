require 'json'

describe Webcast::Audio do

  context 'real data', :textext => true do

    let (:audio_base_url) { URI.parse(Settings.audio_proxy.base_url) }
    let (:rss_url) { "#{audio_base_url}/media/common/courses/spring_2014/rss/english_117s_001_audio.rss"; }
    let (:proxy) { Webcast::Audio.new({:audio_rss => rss_url}) }

    it 'should get real audio data' do
      proxy_response = proxy.get
      expect(proxy_response[:audio]).to have(26).items
    end

    it 'should get valid play URLs' do
      proxy_response = proxy.get
      play_url = "#{audio_base_url}/media/common/courses/spring_2014/media/english_117s_001/3c7be589-95d0-4a94-80b5-836b9f73e668_audio.mp3"
      expect(proxy_response[:audio][0][:playUrl]).to eq play_url
    end

    it 'should get correct download URLs' do
      proxy_response = proxy.get
      download_url = "#{audio_base_url}/download/common/courses/spring_2014/media/english_117s_001/3c7be589-95d0-4a94-80b5-836b9f73e668_audio.mp3"
      expect(proxy_response[:audio][0][:downloadUrl]).to eq download_url
    end

    it 'should get correct titles' do
      proxy_response = proxy.get
      expect(proxy_response[:audio][0][:title]).to eq 'English 117S - 2014-05-01: Audio begins min 06:58 & ends min 51:22'
    end

    context 'on remote server errors' do
      let! (:body) { 'An unknown error occurred.' }
      let! (:status) { 506 }
      before(:each) {
        stub_request(:any, rss_url).to_return(status: status, body: body)
      }
      it 'should deliver empty ' do
        proxy_response = proxy.get
        expect(proxy_response[:audio]).to be_empty
      end
    end

    context 'when xml formatting fails' do
      before(:each) {
        stub_request(:any, rss_url).to_return(status: 200, body: 'bogus xml')
      }
      it 'should return empty array when RSS parsing fails' do
        proxy_response = proxy.get
        expect(proxy_response[:audio]).to be_empty
      end
    end

    context 'on connection errors' do
      before(:each) {
        stub_request(:any, /.#{audio_base_url.hostname}./).to_raise(Errno::ECONNREFUSED)
      }

      it 'should return empty content when HTTP GET fails' do
        proxy_response = proxy.get
        expect(proxy_response[:audio]).to be_empty
      end
    end
  end

  context 'empty RSS feed' do
    let (:proxy) { Webcast::Audio.new({:audio_rss => ''}) }

    it 'should return an empty audio array' do
      proxy_response = proxy.get
      expect(proxy_response[:audio]).to be_empty
    end
  end

end
