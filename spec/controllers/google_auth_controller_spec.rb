require "spec_helper"

describe GoogleAuthController do
  before(:each) do
    @user_id = rand(99999).to_s
  end

  it "should store a dismiss_reminder key-value when there's no token for a user" do
    session[:user_id] = @user_id
    GoogleProxy.stub(:access_granted?).with(@user_id).and_return(false)
    post :dismiss_reminder, { :format => 'json' }
    response.status.should eq(200)
    json_response = JSON.parse(response.body)
    json_response['result'].should be_true
  end

  it "should not store a dismiss_reminder key-value when there's an existing token" do
    session[:user_id] = @user_id
    GoogleProxy.stub(:access_granted?).with(@user_id).and_return(true)
    post :dismiss_reminder, { :format => 'json' }
    response.status.should eq(200)
    json_response = JSON.parse(response.body)
    json_response['result'].should be_false
  end
end
