require "spec_helper"

describe MyClassesController do

  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should be an empty course sites feed on non-authenticated user" do
    get :get_feed
    assert_response :success
    json_response = JSON.parse(response.body)
    json_response.should == {}
  end

  it "should be an non-empty course feed on authenticated user" do
    MyClasses.any_instance.stub(:get_feed).and_return(
      [{course_code: "PLEO 22",
      id: "750027",
      emitter: CanvasProxy::APP_NAME}])
    session[:user_id] = @user_id
    get :get_feed
    json_response = JSON.parse(response.body)
    json_response.size.should == 1
    json_response[0]["course_code"].should == "PLEO 22"
  end

end
