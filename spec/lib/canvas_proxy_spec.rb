require "spec_helper"

describe CanvasProxy do

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    Oauth2Data.new_or_update(@user_id, CanvasProxy::APP_ID,
                             Settings.canvas_proxy.test_user_access_token)
    @client = CanvasProxy.new(:user_id => @user_id)
  end

  it "should see an account list as admin" do
    admin_client = CanvasProxy.new(admin: true)
    response = admin_client.request('accounts', '_admin')
    accounts = JSON.parse(response.body)
    accounts.size.should > 0
  end

  it "should see the same account list as admin, initiating CanvasProxy with a passed in token" do
    admin_client = CanvasProxy.new(:access_token => Settings.canvas_proxy.admin_access_token)
    response = admin_client.request('accounts', '_admin')
    accounts = JSON.parse(response.body)
    accounts.size.should > 0
  end

  it "should get own profile as authorized user", :testext => true do
    response = @client.request('users/self/profile', '_admin')
    profile = JSON.parse(response.body)
    profile['login_id'].should == @user_id.to_s
  end

  it "should get courses as known student", :testext => true do
    response = @client.courses
    courses = JSON.parse(response.body)
    courses.size.should > 0
    courses[0]['course_code'].should_not be_nil
  end

  it "should get the coming_up feed for a known user", :testext => true do
    response = @client.coming_up
    tasks = JSON.parse(response.body)
    tasks[0]["type"].should_not be_nil
    tasks[0]["title"].should_not be_nil
  end

  it "should get the todo feed for a known user", :testext => true do
    response = @client.todo
    tasks = JSON.parse(response.body)
    tasks[0]["assignment"]["name"].should_not be_nil
    tasks[0]["assignment"]["course_id"].should_not be_nil
  end

  it "should get groups as known member", :testext => true do
    response = @client.groups
    groups = JSON.parse(response.body)
    groups.size.should > 0
    groups[0]['name'].should_not be_nil
  end

end
