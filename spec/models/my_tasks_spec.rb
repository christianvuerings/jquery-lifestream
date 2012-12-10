require "spec_helper"

describe "MyTasks" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = GoogleProxy.new({fake: true})
    @fake_google_tasks_array = @fake_google_proxy.tasks_list()
    @fake_canvas_proxy = CanvasProxy.new({fake: true})
  end

  it "should load nicely with the pre-recorded fake Google and Canvas proxy feeds using the server's timezone" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    CanvasProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
    my_tasks_model = MyTasks.new(@user_id, Date.new(2012, 11, 27).to_time_in_current_zone)
    valid_feed = my_tasks_model.get_feed
    valid_feed["sections"].length.should == 5
    valid_feed["sections"][0]["title"].should == "Overdue"
    valid_feed["sections"][0]["tasks"].size.should == 1
    valid_feed["sections"][1]["title"].should == "Due Today"
    valid_feed["sections"][1]["tasks"].size.should == 2
    valid_feed["sections"][2]["title"].should == "Due This Week"
    valid_feed["sections"][2]["tasks"].size.should == 3
    valid_feed["sections"][3]["title"].should == "Due Next Week"
    valid_feed["sections"][3]["tasks"].size.should == 1
    valid_feed["sections"][4]["title"].should == "Unscheduled"
    valid_feed["sections"][4]["tasks"].size.should == 1
    valid_feed["sections"].each do |section|
      section["tasks"].each do |task|
        task["title"].blank?.should == false
        task["source_url"].blank?.should == false

        if task["emitter"] == "Google Tasks"
          task["link_url"].should == "https://mail.google.com/tasks/canvas?pli=1"
          task["class"].should == "google-task"
          if task["due_date"]
            task["due_date"]["date_string"] =~ /\d\d\/\d\d/
            task["due_date"]["epoch"].should >= 1351641600
          end
        end
        if task["emitter"] == CanvasProxy::APP_ID
          task["link_url"].should =~ /https:\/\/ucberkeley.instructure.com\/courses/
          task["link_url"].should == task["source_url"]
          task["color_class"].should == "canvas-class"
          task["due_date"]["date_string"] =~ /\d\d\/\d\d/
          task["due_date"]["epoch"].should >= 1354060800
        end
      end
    end
  end

  it "should shift tasks into different buckets with a different timezone " do
    original_time_zone = Time.zone
    begin
      Time.zone = 'Pacific/Tongatapu'
      GoogleProxy.stub(:access_granted?).and_return(true)
      CanvasProxy.stub(:access_granted?).and_return(true)
      GoogleProxy.stub(:new).and_return(@fake_google_proxy)
      CanvasProxy.stub(:new).and_return(@fake_canvas_proxy)
      my_tasks_model = MyTasks.new(@user_id, Date.new(2012, 11, 27).to_time_in_current_zone)
      valid_feed = my_tasks_model.get_feed
      valid_feed["sections"][0]["title"].should == "Overdue"
      valid_feed["sections"][0]["tasks"].size.should == 1
      valid_feed["sections"][1]["title"].should == "Due Today"
      valid_feed["sections"][1]["tasks"].size.should == 0
      valid_feed["sections"][2]["title"].should == "Due This Week"
      valid_feed["sections"][2]["tasks"].size.should == 5
      valid_feed["sections"][3]["title"].should == "Due Next Week"
      valid_feed["sections"][3]["tasks"].size.should == 1
      valid_feed["sections"][4]["title"].should == "Unscheduled"
      valid_feed["sections"][4]["tasks"].size.should == 1
    ensure
      Time.zone = original_time_zone
    end
  end

  it "should fail general update_tasks param validation, missing required parameters" do
    my_tasks = MyTasks.new @user_id
    expect {
      my_tasks.update_task({"foo" => "badly formatted entry"})
    }.to raise_error { |error|
      error.should be_a(ArgumentError)
      (error.message =~ (/Missing parameter\(s\). Required: \[/)).nil?.should_not == true
    }
  end

  it "should fail general update_tasks param validation, invalid parameter(s)" do
    my_tasks = MyTasks.new @user_id
    expect {
      my_tasks.update_task({"type" => "sometype", "emitter" => "Canvas", "status" => "half-baked" })
    }.to raise_error { |error|
      error.should be_a(ArgumentError)
      error.message.should == "Invalid parameter for: status"
    }
  end

  it "should fail google update_tasks param validation, invalid parameter(s)" do
    my_tasks = MyTasks.new @user_id
    GoogleProxy.stub(:access_granted?).and_return(true)
    expect {
      my_tasks.update_task({"type" => "sometype", "emitter" => "Google Tasks", "status" => "completed" })
    }.to raise_error { |error|
      error.should be_a(ArgumentError)
      error.message.should == "Missing parameter(s). Required: [\"id\"]"
    }
  end

  it "should fail google update_tasks with unauthorized access" do
    my_tasks = MyTasks.new @user_id
    GoogleProxy.stub(:access_granted?).and_return(false)
    response = my_tasks.update_task({"type" => "sometype", "emitter" => "Google Tasks", "status" => "completed", "id" => "foo"})
    response.should == {}
  end

  # Will fail in this case since the task_list_id won't match what's recorded in vcr, nor is a valid "remote" task id.
  it "should fail google update_tasks with a remote proxy error" do
    my_tasks = MyTasks.new @user_id
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    response = my_tasks.update_task({"type" => "sometype", "emitter" => "Google Tasks", "status" => "completed", "id" => "foo"})
    response.should == {}
  end

  it "should succeed google update_tasks with a properly formatted params" do
    my_tasks = MyTasks.new @user_id
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    #slightly roundabout way to get the task_list_ids and task_ids
    proxy = GoogleProxy.new(:fake => true)
    test_task_list = proxy.create_task_list '{"title": "test"}'
    test_task_list.response.status.should == 200
    task_list_id = test_task_list.data["id"]
    new_task = proxy.insert_task(body='{"title": "New Task", "notes": "Please Complete me"}', task_list_id=task_list_id)
    new_task.response.status.should == 200
    task_id = new_task.data["id"]
    response = my_tasks.update_task({"type" => "sometype", "emitter" => "Google Tasks", "status" => "completed", "id" => task_id}, task_list_id)
    response["type"].should == "task"
    response["id"].should == task_id
    response["emitter"].should == "Google Tasks"
    response["status"].should == "completed"
  end

end
