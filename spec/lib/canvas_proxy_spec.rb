require "spec_helper"

describe CanvasProxy do

  it "should see an account list as admin" do
    client = CanvasProxy.new(admin: true)
    response = client.request('accounts')
    accounts = JSON.parse(response.body)
    accounts.size.should > 0
  end

  it "should get own profile as authorized user" do
    user_id = '211159'
    client = CanvasProxy.new(user_id: user_id)
    response = client.request('users/self/profile')
    profile = JSON.parse(response.body)
    profile['sis_user_id'].should == user_id
  end

  it "should get courses as known student" do
    user_id = '211159'
    client = CanvasProxy.new(user_id: user_id)
    response = client.courses
    courses = JSON.parse(response.body)
    courses.size.should > 0
    courses[1]['course_code'].should_not be_nil
  end

end
