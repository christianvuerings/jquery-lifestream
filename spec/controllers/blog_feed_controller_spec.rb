describe BlogFeedController do

  describe 'with legacy alerts feed' do
    before do
      allow(Settings.features).to receive('service_alerts_rss').and_return(false)
      allow_any_instance_of(EtsBlog::Alerts).to receive(:get_latest).and_return(fake_alerts)
      allow(EtsBlog::ServiceAlerts).to receive(:new).exactly(0).times
    end

    let!(:nonempty_alert_feed) do
      EtsBlog::Alerts.new({fake:true}).get_latest
    end

    context 'when there are alerts' do
      let(:fake_alerts) { nonempty_alert_feed }
      it 'should return both an alert and a release note for non-authenticated users' do
        get :get_blog_info
        assert_response :success
        response.status.should == 200
        json_response = JSON.parse(response.body)
        json_response["alert"].should be_present
        json_response["releaseNote"].should be_present
      end
    end

    context 'when there are alerts' do
      let(:fake_alerts) { nil }
      it 'should return only a release note for non-authenticated users' do
        get :get_blog_info
        assert_response :success
        response.status.should == 200
        json_response = JSON.parse(response.body)
        json_response["alert"].should be_blank
        json_response["releaseNote"].should be_present
      end
    end
  end

  describe 'with hosted alerts RSS feed' do
    before do
      allow(Settings.features).to receive('service_alerts_rss').and_return(true)
      allow_any_instance_of(EtsBlog::ServiceAlerts).to receive(:get_latest).and_return(fake_alerts)
      allow(EtsBlog::Alerts).to receive(:new).exactly(0).times
    end

    let!(:nonempty_alert_feed) do
      EtsBlog::ServiceAlerts.new({fake:true}).get_latest
    end

    context 'when there are alerts' do
      let(:fake_alerts) { nonempty_alert_feed }
      it 'should return both an alert and a release note for non-authenticated users' do
        get :get_blog_info
        assert_response :success
        response.status.should == 200
        json_response = JSON.parse(response.body)
        json_response["alert"].should be_present
        json_response["releaseNote"].should be_present
      end
    end

    context 'when there are alerts' do
      let(:fake_alerts) { nil }
      it 'should return only a release note for non-authenticated users' do
        get :get_blog_info
        assert_response :success
        response.status.should == 200
        json_response = JSON.parse(response.body)
        json_response["alert"].should be_blank
        json_response["releaseNote"].should be_present
      end
    end
  end


end
