describe Webcast::SystemStatus do

  let (:system_status_json_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/warehouse/webcast-system-status.json" }

  context 'a fake proxy' do
    subject { Webcast::SystemStatus.new({:fake => true}) }

    context 'fake data' do
      it 'should return webcast-enabled rooms' do
        expect(subject.get[:isSignUpActive]).to be true
      end
    end

    context 'when video feature flag is false' do
      before { Settings.features.videos = false }
      after { Settings.features.videos = true }
      it 'should be false regardless of value in the feed' do
        expect(subject.get[:isSignUpActive]).to be false
      end
    end
  end

  context 'a real, non-fake proxy' do
    subject { Webcast::SystemStatus.new }

    context 'real data', :testext => true do
      it 'should return true or false' do
        flag = subject.get[:isSignUpActive]
        expect([true, false]).to include flag
      end
    end
  end
end
