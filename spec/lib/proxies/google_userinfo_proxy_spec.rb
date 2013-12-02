require "spec_helper"

describe "GoogleDriveListProxy" do

  begin
    @random_id = rand(99999).to_s
  end

  it "Should return a valid list of drive files" do
    userinfo_proxy = GoogleUserinfoProxy.new :fake => true
    userinfo_proxy.class.api.should == "userinfo"
    response = userinfo_proxy.user_info
    %w(email verified_email name id).each do |key|
      response.data[key].blank?.should_not be_true
    end
  end

end
