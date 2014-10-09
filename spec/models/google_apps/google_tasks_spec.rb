require "spec_helper"

describe "GoogleTaskList" do

  before do
    @random_id = rand(999999).to_s
  end

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end

  # simulates creating a tasklist, create a task, toggle statuses back and forth, delete tasklist.
  it "should simulate a fake task toggle between statuses" do
    proxy_opts = {
      :fake => true
    }
    if ENV["RAILS_ENV"] == "testext"
      proxy_opts = {
        :access_token => Settings.google_proxy.test_user_access_token,
        :refresh_token => Settings.google_proxy.test_user_refresh_token,
        :expiration_time => 0
      }
    end

    # Create task list
    create_proxy = GoogleApps::CreateTaskList.new proxy_opts
    test_task_list = create_proxy.create_task_list '{"title": "test"}'
    test_task_list.response.status.should == 200
    test_task_list.data["kind"].should == "tasks#taskList"
    test_task_list_id = test_task_list.data["id"]
    test_task_list_id.blank?.should_not == true

    # Insert task
    insert_proxy = GoogleApps::InsertTask.new proxy_opts
    new_task = insert_proxy.insert_task(task_list_id=test_task_list_id, body='{"title": "New Task", "notes": "Please Complete me"}')
    new_task.response.status.should == 200
    new_task.data["title"].should == "New Task"
    new_task.data["status"].should == "needsAction"
    new_task_id = new_task.data["id"]
    new_task_id.blank?.should_not == true

    # Update task: toggling pieces we're interested in testing.
    template = {id: new_task_id, status: "needsAction"}
    completed = template.clone
    completed[:status] = "completed"
    update_proxy = GoogleApps::UpdateTask.new proxy_opts
    completed_response = update_proxy.update_task(test_task_list_id, new_task_id, completed)
    completed_response.response.status.should == 200
    completed_response.data["status"].should == "completed"
    completed_response.data["completed"].blank?.should_not == true
    needsAction_response = update_proxy.update_task(test_task_list_id, new_task_id, template)
    needsAction_response.response.status.should == 200
    needsAction_response.data["status"].should == "needsAction"
    needsAction_response.data["completed"].blank?.should == true

    # Insert another task that should get cleared away in clear completed tasks
    another_task = insert_proxy.insert_task(task_list_id=test_task_list_id, body='{"title": "Already completed", "notes": "Already completed"}')
    another_task_id = another_task.data["id"]
    another_task.response.status.should == 200
    another_completed = completed.clone
    another_completed[:id] = another_task_id
    completed_response = update_proxy.update_task(test_task_list_id, another_task_id, another_completed)
    completed_response.response.status.should == 200

    # Clear completed tasks from tasklist
    clear_completed_tasklist_proxy = GoogleApps::ClearTaskList.new proxy_opts
    clear_completed_response = clear_completed_tasklist_proxy.clear_task_list test_task_list_id
    clear_completed_response.should be_truthy
    get_tasks_proxy = GoogleApps::TasksList.new proxy_opts
    response = get_tasks_proxy.tasks_list(optional_params={:tasklist => test_task_list_id}).first
    response.data["kind"].should == "tasks#tasks"
    response.data["items"].each do |entry|
      entry["id"].should_not == test_task_list_id
    end

    #Delete task
    delete_proxy = GoogleApps::DeleteTask.new proxy_opts
    response = delete_proxy.delete_task(test_task_list_id, new_task_id)
    response.should be_truthy

    # Delete task list
    delete_proxy = GoogleApps::DeleteTaskList.new proxy_opts
    suppress_rails_logging {
      delete_response = delete_proxy.delete_task_list(test_task_list_id)
      delete_response.should == true
    }
  end

end
