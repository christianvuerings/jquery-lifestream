require "spec_helper"

describe MyActivitiesController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty activities feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty activities feed on authenticated user" do
    session[:user_id] = @user_id
    dummy = JSON.parse(File.read(Rails.root.join('public/dummy/json/activities.json')))
    MyActivities::Merged.any_instance.stub(:get_feed).and_return(dummy)
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.should_not == {}
    json_response["activities"].instance_of?(Array).should == true
  end

  it "should return a valid activities feed for an authenticated user" do
    session[:user_id] = @user_id
    dummy = JSON.parse(File.read(Rails.root.join('public/dummy/json/activities.json')))
    MyActivities::Merged.any_instance.stub(:get_feed).and_return(dummy)
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response["activities"].instance_of?(Array).should == true
    json_response["activities"].each do | activity |
      %w(type source emitter color_class).each do | req_field |
        activity[req_field].blank?.should_not == true
      end
    end
  end
end
