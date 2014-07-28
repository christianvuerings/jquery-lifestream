require "spec_helper"

describe GoogleApps::Userinfo do

  begin
    @random_id = rand(99999).to_s
  end

  it "Should return a valid list of drive files" do
    userinfo_proxy = GoogleApps::Userinfo.new :fake => true
    userinfo_proxy.class.api.should == "userinfo"
    response = userinfo_proxy.user_info
    %w(emails name id).each do |key|
      response.data[key].blank?.should_not be_true
    end
  end

end
