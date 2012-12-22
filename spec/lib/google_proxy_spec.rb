require "spec_helper"

describe GoogleProxy do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
  end

  it "should simulate a fake, valid event list response (assuming a valid recorded fixture)" do
    #Pre-recorded response has 13 entries, split into batches of 10.
    proxy = GoogleProxy.new(:fake => true)
    response_array = proxy.events_list({:maxResults => 10})

    #sample response payload: https://developers.google.com/google-apps/calendar/v3/reference/events/list
    response_array[0].data["kind"].should == "calendar#events"
    response_array.size.should == 2
    (response_array[0].data["items"].size + response_array[1].data["items"].size).should == 13
  end

  it "should return a fake event list response that matches what the UI sends for the up-next widget in fake mode" do
    today = Date.today.to_time_in_current_zone.to_datetime
    proxy = GoogleProxy.new(:fake => true)
    response_array = proxy.events_list(
        {
            :maxResults => 1000,
            :timeMin => today.rfc3339,
            :timeMax => today.advance(:days => 1).rfc3339,
            :orderBy => "startTime",
            :singleEvents => true
        })
    response_array.size.should == 1
    response_array[0].data["items"].size.should == 5
  end

  it "should simulate a fake, valid task list response (assuming a valid recorded fixture)" do
    #Pre-recorded response has 13 entries, split into batches of 10.
    proxy = GoogleProxy.new(:fake => true)
    response_array = proxy.tasks_list

    #sample response payload: https://developers.google.com/google-apps/tasks/v1/reference/tasks/list
    response_array[0].data["kind"].should == "tasks#tasks"
    response_array[0].data["items"].size.should == 6
  end

  # simulates creating a tasklist, create a task, toggle statuses back and forth, delete tasklist.
  it "should simulate a fake task toggle between statuses" do
    if ENV["RAILS_ENV"] == "testext"
      proxy = GoogleProxy.new(
        :access_token => Settings.google_proxy.test_user_access_token,
        :refresh_token => Settings.google_proxy.test_user_refresh_token,
        :expiration_time => 0
      )
    end
    proxy ||= GoogleProxy.new(:fake => true)
    test_task_list = proxy.create_task_list '{"title": "test"}'
    test_task_list.response.status.should == 200
    test_task_list.data["kind"].should == "tasks#taskList"
    test_task_list_id = test_task_list.data["id"]
    test_task_list_id.blank?.should_not == true
    new_task = proxy.insert_task(body='{"title": "New Task", "notes": "Please Complete me"}', task_list_id=test_task_list_id)
    new_task.response.status.should == 200
    new_task.data["title"].should == "New Task"
    new_task.data["status"].should == "needsAction"
    new_task_id = new_task.data["id"]
    new_task_id.blank?.should_not == true

    #the toggling pieces we're interested in testing.
    template = {id: new_task_id, status: "needsAction"}
    completed = template.clone
    completed[:status] = "completed"
    completed_response = proxy.update_task(test_task_list_id, new_task_id, completed)
    completed_response.response.status.should == 200
    completed_response.data["status"].should == "completed"
    completed_response.data["completed"].blank?.should_not == true
    needsAction_response = proxy.update_task(test_task_list_id, new_task_id, template)
    needsAction_response.response.status.should == 200
    needsAction_response.data["status"].should == "needsAction"
    needsAction_response.data["completed"].blank?.should == true

    delete_response = proxy.delete_task_list(test_task_list_id)
    delete_response.should == true
  end

  it "should simulate a token update before a real request using the Tammi account", :testext => true do
    # by the time the fake access token is used below, it probably has well expired
    Oauth2Data.new_or_update(@random_id, GoogleProxy::APP_ID,
                             Settings.google_proxy.test_user_access_token, Settings.google_proxy.test_user_refresh_token, 0)
    proxy = GoogleProxy.new(:user_id => @random_id)
    GoogleProxy.access_granted?(@random_id).should be_true
    old_token = proxy.client.authorization.access_token
    response_array = proxy.events_list()
    response_array[0].data["kind"].should == "calendar#events"
    proxy.client.authorization.access_token.should_not == old_token
  end

  it "should simulate revoking a token after a 401 response", :testext => true do
    Oauth2Data.new_or_update(@random_id, GoogleProxy::APP_ID,
                             "bogus_token", "bogus_refresh_token", 0)
    proxy = GoogleProxy.new(:user_id => @random_id)
    GoogleProxy.access_granted?(@random_id).should be_true
    proxy.client.authorization.stub(:expired?).and_return(false)
    response_array = proxy.events_list()
    GoogleProxy.access_granted?(@random_id).should be_false
  end

  it "should simulate a dynamically set token params request", :testext => true do
    proxy = GoogleProxy.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    response_array = proxy.events_list()
    response_array[0].data["kind"].should == "calendar#events"
  end

  it "should simulate a task list request", :testext => true do
    proxy = GoogleProxy.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    response_array = proxy.tasks_list
    response_array[0].data["kind"].should == "tasks#tasks"
  end

end