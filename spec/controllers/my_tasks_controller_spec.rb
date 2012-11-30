require "spec_helper"

describe MyTasksController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty task feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty task feed on authenticated user" do
    session[:user_id] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.should_not == {}
    json_response["sections"].length.should == 4
    default_sections = ["Due", "Due Tomorrow", "Upcoming", "Unscheduled"]
    json_response["sections"].each do |section|
      default_sections.include?(section["title"]).should == true
    end

  end
end
