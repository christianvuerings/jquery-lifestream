require "spec_helper"

describe "GoogleDriveList" do

  after do
    # Making sure we return cassettes back to the store after we're done.
    VCR.eject_cassette
  end

  it "should get real drive docs list using the Tammi account", :testext => true do
    proxy_opts = {
      :fake => false,
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    }

    drive_list_proxy = GoogleApps::DriveList.new proxy_opts
    response = drive_list_proxy.drive_list
    response.kind_of?(Enumerable).should be_truthy
    # Should help raise concerns if recordings goes wrong
    response.each do |response_page|
      response_page.status.should == 200
      response_page.data["kind"].should == "drive#fileList"
      response_page.data["items"].kind_of?(Array).should be_truthy
    end
  end
end
