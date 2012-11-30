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

  it "should simulate a fake, valid task list response (assuming a valid recorded fixture)" do
    #Pre-recorded response has 13 entries, split into batches of 10.
    proxy = GoogleProxy.new(:fake => true)
    response_array = proxy.tasks_list

    #sample response payload: https://developers.google.com/google-apps/tasks/v1/reference/tasks/list
    response_array[0].data["kind"].should == "tasks#tasks"
    response_array[0].data["items"].size.should == 6
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