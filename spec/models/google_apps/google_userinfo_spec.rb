require "spec_helper"

describe "GoogleUserinfo" do

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end

  it "should get real userinfo.profile using the Tammi account", :testext => true do
    proxy_opts = {
      :fake => false,
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    }
    userinfo_proxy = GoogleApps::Userinfo.new proxy_opts
    response = userinfo_proxy.user_info
    %w(emails name id).each do |key|
      response.data[key].blank?.should_not be_true
    end
  end
end
