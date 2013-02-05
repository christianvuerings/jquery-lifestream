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
    json_response["tasks"].length.should > 0
    json_response["tasks"].each do |task|
      task.include?("title").should == true
    end
  end

  it "should return a valid json object on a successful task update" do
    session[:user_id] = @user_id
    hash = {"someKey" => "someValue"}
    MyTasks::Merged.any_instance.stub(:update_task).and_return(hash)
    post :update_task, {key: "value"}
    json_response = JSON.parse(response.body)
    json_response.should_not == {}
    json_response.should == hash
  end

  it "should return a 400 error on some ArgumentError with the task model object" do
    session[:user_id] = @user_id
    error_msg = "some fatal issue"
    MyTasks::Merged.any_instance.stub(:update_task).and_raise(ArgumentError, error_msg)
    post :update_task, {key: "value"}
    response.status.should == 400
    json_response = JSON.parse(response.body)
    json_response["error"].should == "Invalid Arguments"
    json_response["message"].should == error_msg
  end
end
