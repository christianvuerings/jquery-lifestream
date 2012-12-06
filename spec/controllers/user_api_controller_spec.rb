require "spec_helper"

describe UserApiController do

  it "should not have a logged-in status" do
    get :mystatus
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response["is_logged_in"].should == false
    json_response["uid"].should be_nil
  end

  it "should show status for a logged-in user" do
    session[:user_id] = "192517"
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["is_logged_in"].should == true
    json_response["uid"].should == "192517"
    json_response["preferred_name"].should == "Yu-Hung Lin"
  end

  it "should record first login for a new user" do
    session[:user_id] = "192517"
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["first_login_at"].should == nil
    get :record_first_login
    response.status.should == 204
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["first_login_at"].should_not == nil
  end

end
