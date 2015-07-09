require "spec_helper"

describe BlogFeedController do

  let!(:nonempty_alert_feed) do
    EtsBlog::Alerts.new({fake:true}).get_latest
  end

  before do
    allow_any_instance_of(EtsBlog::Alerts).to receive(:get_latest).and_return(fake_alerts)
  end

  context 'when there are alerts' do
    let(:fake_alerts) { nonempty_alert_feed }
    it 'should return both an alert and a release note for non-authenicated users' do
      get :get_blog_info
      assert_response :success
      response.status.should == 200
      json_response = JSON.parse(response.body)
      json_response["alert"].should be_present
      json_response["release_note"].should be_present
    end
  end

  context 'when there are alerts' do
    let(:fake_alerts) { nil }
    it 'should return only a release note for non-authenicated users' do
      get :get_blog_info
      assert_response :success
      response.status.should == 200
      json_response = JSON.parse(response.body)
      json_response["alert"].should be_blank
      json_response["release_note"].should be_present
    end
  end

end
