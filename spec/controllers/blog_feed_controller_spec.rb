require "spec_helper"

describe BlogFeedController do

  before do
    @alert_ok = EtsBlog::Alerts.new({fake:true}).get_latest;
    @alert_ko = EtsBlog::Alerts.new({fake:true}).stub(:get_latest).and_return('');
  end

  it "should return an alert and entries for non-authenticated users" do
    get :get_blog_info
    assert_response :success
    response.status.should == 200
    json_response = JSON.parse(response.body)
    json_response.is_a?(Hash).should be_true
    json_response["alert"].is_a?(Hash).should be_true if @alert_ok
    json_response["alert"].should be_nil if @alert_ko
    json_response["entries"].present?.should be_true
    json_response["entries"].is_a?(Array).should be_true
    json_response["entries"].count.should > 0
  end

end
