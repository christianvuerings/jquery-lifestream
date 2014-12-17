require "spec_helper"

describe "MyTasks" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_tasks_list_proxy = GoogleApps::TasksList.new({fake: true})
    @fake_google_update_task_proxy = GoogleApps::UpdateTask.new({fake: true})
    @fake_google_clear_completed_tasks_proxy = GoogleApps::ClearTaskList.new({fake: true})
    @fake_google_tasks_array = @fake_google_tasks_list_proxy.tasks_list
    @real_google_tasks_list_proxy = GoogleApps::TasksList.new(:access_token => Settings.google_proxy.test_user_access_token,
                                                             :refresh_token => Settings.google_proxy.test_user_refresh_token,
                                                             :expiration_time => 0)
    @real_google_update_task_proxy = GoogleApps::UpdateTask.new(:access_token => Settings.google_proxy.test_user_access_token,
                                                               :refresh_token => Settings.google_proxy.test_user_refresh_token,
                                                               :expiration_time => 0)
    @real_google_clear_completed_tasks_proxy = GoogleApps::ClearTaskList.new(:access_token => Settings.google_proxy.test_user_access_token,
                                                                            :refresh_token => Settings.google_proxy.test_user_refresh_token,
                                                                            :expiration_time => 0)
    @fake_canvas_proxy = Canvas::Proxy.new({fake: true})
    @fake_canvas_upcoming_events_proxy = Canvas::UpcomingEvents.new({fake: true})
    @fake_canvas_todo_proxy = Canvas::Todo.new({fake: true})
    @fake_canvas_courses = Canvas::UserCourses.new({fake: true}).courses

  end

  it "should load nicely with the pre-recorded fake Google and Canvas proxy feeds using the server's timezone" do
    original_time_zone = Time.zone
    begin
      Time.zone = 'America/Los_Angeles'
      GoogleApps::Proxy.stub(:access_granted?).and_return(true)
      Canvas::Proxy.stub(:access_granted?).and_return(true)
      GoogleApps::TasksList.stub(:new).and_return(@fake_google_tasks_list_proxy)
      Canvas::UpcomingEvents.stub(:new).and_return(@fake_canvas_upcoming_events_proxy)
      Canvas::Todo.stub(:new).and_return(@fake_canvas_todo_proxy)
      my_tasks_model = MyTasks::Merged.new(@user_id)
      valid_feed = my_tasks_model.get_feed

      # Counts for task types in VCR recording
      overdue_counter = 5
      # On Sundays, no "later in the week" tasks can escape the "Today" bucket. Since this moves
      # some "Future" tasks to "Today", more total tasks will be in the feed on Sunday.
      if Time.zone.today.sunday?
        today_counter = 7
        future_counter = 8
      else
        today_counter = 2
        future_counter = 13
      end
      unscheduled_counter = 2

      valid_feed["tasks"].each do |task|
        task["title"].blank?.should == false
        task["sourceUrl"].blank?.should == false

        # Whitelist allowed property strings
        whitelist = task["bucket"] =~ (/(Overdue|Today|Future|Unscheduled)$/i)
        whitelist.should_not be_nil

        case task["bucket"]
          when "Overdue"
            overdue_counter -= 1
          when "Today"
            today_counter -= 1
          when "Future"
            future_counter -= 1
          when "Unscheduled"
            unscheduled_counter -= 1
        end

        if task["emitter"] == GoogleApps::Proxy::APP_ID
          task["linkUrl"].should == "https://mail.google.com/tasks/canvas?pli=1"
          if task["dueDate"]
            task["dueDate"]["dateString"] =~ /\d\d\/\d\d/
            task["dueDate"]["epoch"].should >= 1351641600
          end
        end
        if task["emitter"] == Canvas::Proxy::APP_NAME
          task["linkUrl"].should =~ /https:\/\/ucberkeley.instructure.com\/courses/
          task["linkUrl"].should == task["sourceUrl"]
          if task["dueDate"]
            task["dueDate"]["dateString"] =~ /\d\d\/\d\d/
            task["dueDate"]["epoch"].should >= 1351641600
          end
        end
      end

      overdue_counter.should == 0
      today_counter.should == 0
      future_counter.should == 0
      unscheduled_counter.should == 0
    ensure
      Time.zone = original_time_zone
    end
  end

  it "should fail general update_tasks param validation, missing required parameters" do
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    my_tasks = MyTasks::Merged.new @user_id
    expect {
      my_tasks.update_task({"emitter" => Canvas::Proxy::APP_NAME, "foo" => "badly formatted entry"})
    }.to raise_error { |error|
      error.should be_a(ArgumentError)
      (error.message =~ (/Missing parameter\(s\). Required: \[/)).nil?.should_not == true
    }
  end

  it "should fail general update_tasks param validation, invalid parameter(s)" do
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    my_tasks = MyTasks::Merged.new @user_id
    expect {
      my_tasks.update_task({"type" => "sometype", "emitter" => "bCourses", "status" => "half-baked" })
    }.to raise_error { |error|
      error.should be_a(ArgumentError)
      error.message.should == "Invalid parameter for: status"
    }
  end

  it "should fail google update_tasks param validation, invalid parameter(s)" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    my_tasks = MyTasks::Merged.new @user_id
    expect {
      my_tasks.update_task({"type" => "sometype", "emitter" => GoogleApps::Proxy::APP_ID, "status" => "completed" })
    }.to raise_error { |error|
      error.should be_a(ArgumentError)
      error.message.should == "Missing parameter(s). Required: [\"id\"]"
    }
  end

  it "should fail google update_tasks with unauthorized access" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(false)
    my_tasks = MyTasks::Merged.new @user_id
    response = my_tasks.update_task({"type" => "sometype", "emitter" => GoogleApps::Proxy::APP_ID, "status" => "completed", "id" => "foo"})
    response.should == {}
  end

  # Will fail in this case since the task_list_id won't match what's recorded in vcr, nor is a valid "remote" task id.
  it "should fail google update_tasks with a remote proxy error" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::UpdateTask.stub(:new).and_return(@fake_google_update_task_proxy)
    my_tasks = MyTasks::Merged.new @user_id
    suppress_rails_logging {
      response = my_tasks.update_task({"type" => "sometype", "emitter" => GoogleApps::Proxy::APP_ID, "status" => "completed", "id" => "foo"})
      response.should == {}
    }
  end

  it "should succeed google update_tasks with a properly formatted params" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::UpdateTask.stub(:new).and_return(@fake_google_update_task_proxy)
    my_tasks = MyTasks::Merged.new @user_id
    task_list_id, task_id = get_task_list_id_and_task_id
    response = my_tasks.update_task({"title" => "some bogus title", "notes" => "some bogus notes", "type" => "sometype", "emitter" => GoogleApps::Proxy::APP_ID, "status" => "completed", "id" => task_id}, task_list_id)
    response["type"].should == "task"
    response["id"].should == task_id
    response["emitter"].should == GoogleApps::Proxy::APP_ID
    response["status"].should == "completed"
    response["title"].should == "some bogus title"
    response["notes"].should == "some bogus notes"
  end

  it "should invalidate merged cache and google tasks cache on an update_task for google" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::UpdateTask.stub(:new).and_return(@fake_google_update_task_proxy)
    my_tasks = MyTasks::Merged.new @user_id
    Rails.cache.should_receive(:fetch).with(MyTasks::Merged.cache_key(@user_id), anything())
    my_tasks.get_feed
    task_list_id, task_id = get_task_list_id_and_task_id
    Rails.cache.should_receive(:delete).with(MyTasks::Merged.cache_key(@user_id))
    Rails.cache.should_receive(:delete).with(MyTasks::Merged.cache_key("json-#{@user_id}"))
    Rails.cache.should_receive(:delete).with(MyTasks::GoogleTasks.cache_key(@user_id))
    response = my_tasks.update_task({"type" => "sometype", "emitter" => GoogleApps::Proxy::APP_ID, "status" => "completed", "id" => task_id}, task_list_id)
  end

  it "should return Google tasks when Canvas service is unavailable" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::TasksList.stub(:new).and_return(@fake_google_tasks_list_proxy)
    Canvas::Proxy.any_instance.stub(:request).and_return(nil)
    my_tasks_model = MyTasks::Merged.new(@user_id)
    tasks = my_tasks_model.get_feed["tasks"]
    tasks.size.should be > 0
    tasks.each do |task|
      task["emitter"].should == GoogleApps::Proxy::APP_ID
    end
  end

  it "should clear completed Google tasks" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::ClearTaskList.stub(:new).and_return(@fake_google_clear_completed_tasks_proxy)
    my_tasks_model = MyTasks::Merged.new(@user_id)
    response = my_tasks_model.clear_completed_tasks params={"emitter" => "Google"}
    response.should == {:tasksCleared => true}
  end

  it "should do nothing to Canvas Tasks" do
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    my_tasks_model = MyTasks::Merged.new(@user_id)
    response = my_tasks_model.clear_completed_tasks params={"emitter" => "bCourses"}
    response.should == {:tasksCleared => false}
  end

  it "should simulate a non-responsive google", :testext => true do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleApps::TasksList.stub(:new).and_return(@real_google_tasks_list_proxy)
    GoogleApps::UpdateTask.stub(:new).and_return(@real_google_update_task_proxy)
    GoogleApps::ClearTaskList.stub(:new).and_return(@real_google_clear_completed_tasks_proxy)
    my_tasks_model = MyTasks::Merged.new(@user_id)
    response = my_tasks_model.clear_completed_tasks params={"emitter" => "Google"}
    response.should == {:tasksCleared => false}
    response = my_tasks_model.update_task({"type" => "sometype", "emitter" => GoogleApps::Proxy::APP_ID, "status" => "completed", "id" => "1"}, "1")
    response.should == {}
    valid_feed = my_tasks_model.get_feed
    valid_feed["tasks"].select {|entry| entry["emitter"] == "Google"}.empty?.should be_truthy
  end

  it "should not explode on Canvas feeds that have invalid json" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(false)
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    Canvas::UpcomingEvents.stub(:new).and_return(@fake_canvas_upcoming_events_proxy)
    Canvas::Todo.stub(:new).and_return(@fake_canvas_todo_proxy)
    unparseable = OpenStruct.new(:status => 200, :body => "unparseable")
    Canvas::UpcomingEvents.any_instance.stub(:upcoming_events).and_return(unparseable)
    Canvas::Todo.any_instance.stub(:todo).and_return(unparseable)

    my_tasks_model = MyTasks::Merged.new(@user_id)
    valid_feed = my_tasks_model.get_feed
    valid_feed["tasks"].length.should == 0
  end

  it "should return valid course code for bCourses assignment tasks" do
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    Canvas::UpcomingEvents.stub(:new).and_return(@fake_canvas_upcoming_events_proxy)
    Canvas::Todo.stub(:new).and_return(@fake_canvas_todo_proxy)
    Canvas::UserCourses.stub(:courses).and_return(@fake_canvas_courses)

    my_tasks_model = MyTasks::Merged.new(@user_id)
    valid_feed = my_tasks_model.get_feed
    valid_feed["tasks"].length.should > 0
    course_codes = []
    @fake_canvas_courses.each do |canvas_course|
      course_codes.push(canvas_course["course_code"])
    end

    valid_feed["tasks"].each do |task|
      if task["type"] == "assignment" && task["emitter"] == "bCourses"
        task["course_code"].blank?.should == false
        course_codes.include?(task["course_code"]).should == true
      end
    end
  end

end

def get_task_list_id_and_task_id
  #slightly roundabout way to get the task_list_ids and task_ids
  create_proxy = GoogleApps::CreateTaskList.new(:fake => true)
  test_task_list = create_proxy.create_task_list '{"title": "test"}'
  test_task_list.response.status.should == 200
  task_list_id = test_task_list.data["id"]
  insert_proxy = GoogleApps::InsertTask.new(:fake => true)
  new_task = insert_proxy.insert_task(task_list_id=task_list_id, body='{"title": "New Task", "notes": "Please Complete me"}')
  new_task.response.status.should == 200
  task_id = new_task.data["id"]
  [task_list_id, task_id]
end
