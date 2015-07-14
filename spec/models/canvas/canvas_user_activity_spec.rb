require "spec_helper"

describe Canvas::Proxy do

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    User::Oauth2Data.new_or_update(@user_id, Canvas::Proxy::APP_ID,
                             Settings.canvas_proxy.test_user_access_token)
    @client = Canvas::Proxy.new(:user_id => @user_id)
  end

  after { WebMock.reset! }

  it "should get real user activity feed using the Tammi account", :testext => true do
    proxy = Canvas::UserActivityStream.new(
      :user_id => @user_id
    )
    response = proxy.user_activity
    user_activity = JSON.parse(response.body)
    user_activity.kind_of?(Array).should be_truthy
  end
end
