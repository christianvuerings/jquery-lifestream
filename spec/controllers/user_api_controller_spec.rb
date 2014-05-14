require "spec_helper"

describe UserApiController do

  before do
    @user_id = rand(999999).to_s
  end

  it "should not have a logged-in status" do
    get :mystatus
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response["isLoggedIn"].should == false
    json_response["uid"].should be_nil
    json_response["features"].should_not be_nil
  end

  it "should show status for a logged-in user" do
    session[:user_id] = "238382"
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["isLoggedIn"].should == true
    json_response["uid"].should == "238382"
    json_response["preferred_name"].should_not be_nil
    json_response["features"].should_not be_nil
    visit = User::Visit.where(:uid=>session[:user_id])[0]
    visit.last_visit_at.should_not be_nil
  end

  it "should record first login for a new user" do
    CampusOracle::UserAttributes.stub(:new).and_return(double(get_feed: {
      'person_name' => "Joe Test",
      :roles => {
        :student => true,
        :faculty => false,
        :staff => false
      }
    }))
    session[:user_id] = @user_id
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["firstLoginAt"].should == nil
    get :record_first_login
    response.status.should == 204
    get :mystatus
    json_response = JSON.parse(response.body)
    json_response["firstLoginAt"].should_not be_nil
  end

end
