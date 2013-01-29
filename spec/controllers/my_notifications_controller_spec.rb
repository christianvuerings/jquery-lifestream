require "spec_helper"

describe MyNotificationsController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty notifications feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty notifications feed on authenticated user" do
    session[:user_id] = @user_id
    dummy = JSON.parse(File.read(Rails.root.join('public/dummy/json/notifications.json')))
    MyNotifications.any_instance.stub(:get_feed).and_return(dummy)
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.should_not == {}
    json_response["notifications"].instance_of?(Array).should == true
  end

  it "should return a valid notifications feed for an authenticated user" do
    session[:user_id] = @user_id
    dummy = JSON.parse(File.read(Rails.root.join('public/dummy/json/notifications.json')))
    MyNotifications.any_instance.stub(:get_feed).and_return(dummy)
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response["notifications"].instance_of?(Array).should == true
    json_response["notifications"].each do | notification |
      notification["id"].blank?.should_not == true
      notification["date"]["epoch"].is_a?(Integer).should == true
      %w(type source emitter date color_class).each do | req_field |
        notification[req_field].blank?.should_not == true
      end
    end
  end
end
