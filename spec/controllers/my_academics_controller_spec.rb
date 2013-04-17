require "spec_helper"

describe MyAcademicsController do

  it "should be an empty feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should get a non-empty feed for an authenticated (but fake) user" do
    session[:user_id] = "0"
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response["regblocks"]["active_blocks"].should == []
    json_response["regblocks"]["inactive_blocks"].should == []
  end

end
