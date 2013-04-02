require "spec_helper"

describe MyBadgesController do

  before(:each) do
    @user_id = rand(99999).to_s
    @fake_drive_list_response = GoogleDriveListProxy.new(:fake => true).drive_list
  end

  it "should be an empty badges feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty badges feed on authenticated user" do
    GoogleDriveListProxy.any_instance.stub(:drive_list).and_return(@fake_drive_list_response)
    session[:user_id] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.size.should == 1
    json_response["unread_badge_counts"].empty?.should_not be_true
    existing_badges = %w(bcal bdrive bmail)
    existing_badges.each do |badge|
      json_response["unread_badge_counts"][badge].should_not be_nil
    end

  end

end
