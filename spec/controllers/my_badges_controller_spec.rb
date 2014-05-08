require "spec_helper"

describe MyBadgesController do

  before(:each) do
    @user_id = rand(99999).to_s
    @fake_drive_list = GoogleApps::DriveList.new(:fake => true, :fake_options => {:match_requests_on => [:method, :path]})
    @fake_events_list = GoogleApps::EventsList.new(:fake => true, :fake_options => {:match_requests_on => [:method, :path]})
  end

  it "should be an empty badges feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty badges feed on authenticated user" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::DriveList.stub(:new).and_return(@fake_drive_list)
    GoogleApps::EventsList.stub(:new).and_return(@fake_events_list)
    session[:user_id] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)

    if json_response["alert"].present?
      json_response["alert"].is_a?(Hash).should be_true
      json_response["alert"].keys.count.should >= 3
    end

    json_response["badges"].present?.should be_true
    json_response["badges"].is_a?(Hash).should be_true
    json_response["badges"].keys.count.should == 3

    existing_badges = %w(bcal bdrive bmail)
    existing_badges.each do |badge|
      json_response["badges"][badge]["count"].should_not be_nil
    end

    json_response["studentInfo"].present?.should be_true
    json_response["studentInfo"].is_a?(Hash).should be_true
    json_response["studentInfo"].keys.count.should == 3

  end

end
