require "spec_helper"

describe MyTasksController do

  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_clear_tasks_proxy = GoogleApps::ClearTaskList.new(fake: true)
    @fake_google_delete_tasks_proxy = GoogleApps::DeleteTask.new({fake: true})
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

  it "should return a valid truthy json object when successfully clearing completed google tasks" do
    session[:user_id] = @user_id
    user_payload = {"emitter" => "Google"}
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::ClearTaskList.stub(:new).and_return(@fake_google_clear_tasks_proxy)
    post :clear_completed_tasks, user_payload
    json_response = JSON.parse(response.body)
    json_response.should_not == {}
    json_response.should == {"tasksCleared" => true}
  end

  it "should successfully delete a google task" do
    session[:user_id] = @user_id
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::DeleteTask.stub(:new).and_return(@fake_google_delete_tasks_proxy)
    pre_recorded_tasklist_id = "MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjA"
    pre_recorded_task_id = "MDkwMzQyMTI0OTE3NTY4OTU0MzY6NzAzMjk1MTk3OjEzODE3NzMzNzg"
    valid_delete_response = @fake_google_delete_tasks_proxy.delete_task(pre_recorded_tasklist_id, pre_recorded_task_id)
    GoogleApps::DeleteTask.any_instance.stub(:delete_task).and_return(valid_delete_response)
    hash = {"task_id" => pre_recorded_task_id, "emitter" => "Google"}
    post :delete_task, hash
    json_response = JSON.parse(response.body)
    json_response["task_deleted"].should be_true
  end

  it "should fail on deleting a canvas task" do
    session[:user_id] = @user_id
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    hash = {"task_id" => "gobblygook", "emitter" => "bCourses"}
    post :delete_task, hash
    json_response = JSON.parse(response.body)
    json_response["task_deleted"].should be_false
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

  context 'viewing-as' do
    let(:user_id) { rand(99999).to_s }
    let(:original_user_id) { rand(99999).to_s }
    before do
      session[:user_id] = user_id
      allow(Settings.google_proxy).to receive(:fake).at_least(:once).and_return(true)
      allow(Settings.canvas_proxy).to receive(:fake).at_least(:once).and_return(true)
    end
    context 'with real-user data cached' do
      it 'should not give a real user a cached censored feed' do
        session[:original_user_id] = original_user_id
        get :get_feed
        feed = JSON.parse(response.body)
        expect(feed['tasks'].index {|t| t['emitter'] == 'Google'}).to be_nil
        session[:original_user_id] = nil
        get :get_feed
        feed = JSON.parse(response.body)
        expect(feed['tasks'].index {|t| t['emitter'] == 'Google'}).to_not be_nil
      end
      it 'should not return Google data from a cached real-user feed' do
        get :get_feed
        feed = JSON.parse(response.body)
        expect(feed['tasks'].index {|t| t['emitter'] == 'bCourses'}).to_not be_nil
        expect(feed['tasks'].index {|t| t['emitter'] == 'Google'}).to_not be_nil
        session[:original_user_id] = original_user_id
        get :get_feed
        feed = JSON.parse(response.body)
        expect(feed['tasks'].index {|t| t['emitter'] == 'bCourses'}).to_not be_nil
        expect(feed['tasks'].index {|t| t['emitter'] == 'Google'}).to be_nil
      end
    end
    it 'should not add a Google task to the real user account' do
      session[:original_user_id] = original_user_id
      expect_any_instance_of(MyTasks::GoogleTasks).to receive(:insert_task).never
      hash = {
        'emitter' => 'Google',
        'title' => 'test task'
      }
      post :insert_task, hash
      json_response = JSON.parse(response.body)
      expect(json_response['id']).to be_nil
    end
  end

end
