describe 'Events(events_list)' do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
  end

  it "should simulate a fake, valid event list response (assuming a valid recorded fixture)" do
    #Pre-recorded response has 14 entries, split into batches of 10.
    proxy = GoogleApps::EventsList.new(:fake => true)
    response_array = proxy.events_list({:maxResults => 10}).first 2

    #sample response payload: https://developers.google.com/google-apps/calendar/v3/reference/events/list
    response_array[0].data["kind"].should == "calendar#events"
    response_array.size.should == 2
    (response_array[0].data["items"].size + response_array[1].data["items"].size).should == 14
  end

  it "should return a fake event list response that matches what the UI sends for the up-next widget in fake mode" do
    today = Time.zone.today.in_time_zone.to_datetime
    proxy = GoogleApps::EventsList.new(:fake => true)
    response_array = [
      proxy.events_list(
        {
          :maxResults => 1000,
          :timeMin => today.rfc3339,
          :timeMax => today.advance(:days => 1).rfc3339,
          :orderBy => "startTime",
          :singleEvents => true
        }).first
    ]
    response_array.size.should == 1
    response_array[0].data["items"].size.should == 6
  end

  it "should simulate a token update before a real request using the Tammi account", :testext => true do
    # by the time the fake access token is used below, it probably has well expired
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID,
                             Settings.google_proxy.test_user_access_token, Settings.google_proxy.test_user_refresh_token, 0)
    proxy = GoogleApps::EventsList.new(:user_id => @random_id)
    GoogleApps::Proxy.access_granted?(@random_id).should be_truthy
    old_token = proxy.authorization.access_token
    response = proxy.events_list.first
    response.data["kind"].should == "calendar#events"
    proxy.authorization.access_token.should_not == old_token
  end

  it "should simulate revoking a token after a 401 response", :testext => true do
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID,
                             "bogus_token", "bogus_refresh_token", 0)
    suppress_rails_logging do
      proxy = GoogleApps::EventsList.new(:user_id => @random_id)
      GoogleApps::Proxy.access_granted?(@random_id).should be_truthy
      proxy.authorization.stub(:expired?).and_return(false)
      response_array = proxy.events_list.first
      GoogleApps::Proxy.access_granted?(@random_id).should be_falsey
    end
  end
end
