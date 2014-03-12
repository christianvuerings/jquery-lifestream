require "spec_helper"

describe GoogleProxy do

  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
  end

  it "should simulate a fake, valid task list response (assuming a valid recorded fixture)" do
    #Pre-recorded response has 13 entries, split into batches of 10.
    proxy = GoogleTasksListProxy.new(:fake => true)
    response = proxy.tasks_list.first

    #sample response payload: https://developers.google.com/google-apps/tasks/v1/reference/tasks/list
    response.data["kind"].should == "tasks#tasks"
    response.data["items"].size.should == 6
  end

  it "should simulate a task list request", :testext => true do
    proxy = GoogleTasksListProxy.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    response_enum = proxy.tasks_list
    response_enum.first.data["kind"].should == "tasks#tasks"
  end

end
