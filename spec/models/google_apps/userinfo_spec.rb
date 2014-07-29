require "spec_helper"

describe GoogleApps::Userinfo do

  it 'Should return a valid user profile from fake data' do
    userinfo_proxy = GoogleApps::Userinfo.new :fake => true
    userinfo_proxy.class.api.should == 'userinfo'
    response = userinfo_proxy.user_info
    %w(emails name id).each do |key|
      response.data[key].blank?.should_not be_true
    end
    response.data['emails'].first['value'].should eq 'tammi.chang.clc@gmail.com'
  end

  it 'should get real userinfo.profile using the Tammi account', :testext => true do
    userinfo_proxy = GoogleApps::Userinfo.new(
      {
        :fake => false,
        :access_token => Settings.google_proxy.test_user_access_token,
        :refresh_token => Settings.google_proxy.test_user_refresh_token,
        :expiration_time => 0
      })
    response = userinfo_proxy.user_info
    %w(emails name id).each do |key|
      response.data[key].blank?.should_not be_true
    end
    response.data['emails'].first['value'].should be
  end
end
