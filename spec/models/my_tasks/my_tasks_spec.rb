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

  context 'pre-recorded fake Google and Canvas proxy feeds using the server\'s timezone' do
    before do
      @original_time_zone = Time.zone
      Time.zone = 'America/Los_Angeles'
      allow(GoogleApps::Proxy).to receive(:access_granted?).and_return(true)
      allow(Canvas::Proxy).to receive(:access_granted?).and_return(true)
      allow(GoogleApps::TasksList).to receive(:new).and_return(@fake_google_tasks_list_proxy)
      allow(Canvas::UpcomingEvents).to receive(:new).and_return(@fake_canvas_upcoming_events_proxy)
      allow(Canvas::Todo).to receive(:new).and_return(@fake_canvas_todo_proxy)
    end

    after do
      Time.zone = @original_time_zone
    end

    let(:my_tasks_model) { MyTasks::Merged.new(@user_id) }
    let(:tasks) { my_tasks_model.get_feed['tasks'] }

    it 'should sort tasks into the right buckets' do
      expect(tasks.count{|task| task['bucket'] == 'Overdue'}).to eq 5
      expect(tasks.count{|task| task['bucket'] == 'Unscheduled'}).to eq 2

      # On Sundays, no "later in the week" tasks can escape the "Today" bucket. Since this moves
      # some "Future" tasks to "Today", more total tasks will be in the feed on Sunday.
      if Time.zone.today.sunday?
        expect(tasks.count{|task| task['bucket'] == 'Today'}).to eq 7
        expect(tasks.count{|task| task['bucket'] == 'Future'}).to eq 9
      else
        expect(tasks.count{|task| task['bucket'] == 'Today'}).to eq 2
        expect(tasks.count{|task| task['bucket'] == 'Future'}).to eq 14
      end

      expect(tasks.count{|task| %w(Overdue Today Future Unscheduled).exclude? task['bucket']}).to eq 0
    end

    it 'should include title and sourceUrl fields' do
      expect(tasks.count{|task| task['title'].blank? || task['sourceUrl'].blank?}).to eq 0
    end

    it 'should include correctly formatted due dates' do
      tasks.each do |task|
        next if task['dueDate'].blank?
        expect(task['dueDate']['dateString']).to match(/\A\d{1,2}\/\d{2}\Z/)
        expect(task['dueDate']['epoch']).to be >=(1351641600)
      end
    end

    it 'should include sensible link URLs and descriptions' do
      canvas_tasks = tasks.select { |task| task['emitter'] == Canvas::Proxy::APP_NAME }
      canvas_tasks.each do |task|
        expect(task['linkUrl']).to start_with('https://ucberkeley.instructure.com/courses/')
        expect(task['sourceUrl']).to eq task['linkUrl']
      end
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

  it 'should include an updatedDate for unscheduled Canvas tasks' do
    updated_at = '2015-02-22T00:47:33'
    unscheduled_task_response = OpenStruct.new(status: 200, body: [{
      'assignment' => {
        'course_id' => 903842670,
        'created_at' => '2015-02-15T18:55:44Z',
        'description' => "\u003Cp\u003E\u003Cspan style=\"font-size: medium;\"\u003ETalk back to the book.\u003C/span\u003E\u003C/p\u003E",
        'due_at' => nil,
        'html_url' => 'https://ucberkeley.beta.instructure.com/courses/903842670/assignments/2587242',
        'id' => 2587242,
        'name' => 'Week 5 Reading Response',
        'published' => true,
        'updated_at' => "#{updated_at}Z"
      },
      'context_type' => 'Course',
      'course_id' => 903842670,
      'html_url' => 'https://ucberkeley.beta.instructure.com/courses/903842670/assignments/2587242#submit',
      'type' => 'submitting'
    }].to_json)
    allow_any_instance_of(Canvas::Todo).to receive(:todo).and_return(unscheduled_task_response)

    feed = MyTasks::Merged.new(@user_id).get_feed
    unscheduled_canvas_task = feed['tasks'].find { |task| task['emitter'] == 'bCourses' && task['bucket'] == 'Unscheduled' }
    expect(unscheduled_canvas_task['updatedDate']['epoch']).to be_present
    expect(unscheduled_canvas_task['updatedDate']['dateTime']).to include(updated_at)
    expect(unscheduled_canvas_task['updatedDate']['dateString']).to eq '2/22'
  end

  it 'should set proper date for Google tasks even during timezone transitions' do
    Time.zone = 'America/Los_Angeles'
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    Canvas::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::TasksList.stub(:new).and_return(@fake_google_tasks_list_proxy)
    Canvas::UpcomingEvents.stub(:new).and_return(@fake_canvas_upcoming_events_proxy)
    Canvas::Todo.stub(:new).and_return(@fake_canvas_todo_proxy)

    feed = MyTasks::Merged.new(@user_id).get_feed
    task_for_23_hour_day = feed['tasks'].find { |task| task['emitter'] == 'Google' && task['title'] == 'Set Clocks Forward' }
    epoch = task_for_23_hour_day['dueDate']['epoch']
    expect(Time.at(epoch).strftime('%-m/%d')).to eq task_for_23_hour_day['dueDate']['dateString']
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
