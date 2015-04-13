describe Webcast::SystemStatus do

  let (:system_status_json_uri) { URI.parse "#{Settings.webcast_proxy.base_url}/webcast-system-status.json" }

  context 'a fake proxy' do
    subject { Webcast::SystemStatus.new({:fake => true}) }

    context 'fake data' do
      it 'should return webcast-enabled rooms' do
        expect(subject.get['is_sign_up_active']).to be_truthy
      end
    end
  end

  context 'a real, non-fake proxy' do
    subject { Webcast::SystemStatus.new }

    context 'real data', :testext => true do
      it 'should return true or false' do
        flag = subject.get['is_sign_up_active']
        expect([true, false]).to include flag
      end
    end

  end
end
