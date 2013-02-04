require "spec_helper"

describe CanvasProxy do

  before do
    @user_id = Settings.canvas_proxy.test_user_id
    Oauth2Data.new_or_update(@user_id, CanvasProxy::APP_ID,
                             Settings.canvas_proxy.test_user_access_token)
    @client = CanvasProxy.new(:user_id => @user_id)
  end

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end

  it "should get real user activity feed using the Tammi account", :testext => true do
    proxy = CanvasUserActivityProxy.new(
      :user_id => @user_id
    )
    response = proxy.user_activity
    user_activity = JSON.parse(response.body)
    user_activity.kind_of?(Array).should be_true
  end
end
