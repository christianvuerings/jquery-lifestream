require "spec_helper"

describe UserApiController do

  it "should not have a logged-in status" do
    get :status
    assert_response :success
    JSON.parse(response.body)["is_logged_in"].should == false
  end

  it "should show status for a logged-in user" do
    session[:user_id] = "192517"
    get :status
    json_response = JSON.parse(response.body)
    json_response["is_logged_in"].should == true
    json_response["uid"].should == "192517"
    json_response["preferred_name"].should == "Yu-Hung Lin"
  end

end
