require "spec_helper"

describe User::Oauth2Data do

  before do
    @random_id = rand(999999).to_s
    @fake_google_userinfo = GoogleApps::Userinfo.new(:fake => true).user_info
    @real_google_userinfo = GoogleApps::Userinfo.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    @canvas_404 = OpenStruct.new(
      {
        status: 404,
        body: 'while(1);{"status":"not_found","error_report_id":44351040,"message":"Thespecifiedresourcedoesnotexist."}'
      })
    @fake_canvas_user_profile = Canvas::UserProfile.new(fake: true, user_id: 300846)
  end

  it "should not store plaintext access tokens" do
    User::Oauth2Data.any_instance.stub(:decrypt_tokens).and_return(nil)
    oauth2 = User::Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    oauth2.save.should be_true
    access_token = User::Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should_not == "test-token"
  end

  it "should return decrypted access tokens" do
    oauth2 = User::Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    Cache::UserCacheExpiry.should_receive(:notify).once
    oauth2.save.should be_true
    access_token = User::Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should == "test-token"
  end

  it "should be able to update existing tokens" do
    User::Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                                      "some-token", 1)
    token_hash = User::Oauth2Data.get("test-user", "test-app")
    token_hash["access_token"].should == "new-token"
    token_hash["refresh_token"].should == "some-token"
    token_hash["expiration_time"].should == 1
    Cache::UserCacheExpiry.should_receive(:notify).once
    User::Oauth2Data.new_or_update("test-user", "test-app", "updated-token")
    updated_token_hash = User::Oauth2Data.get("test-user", "test-app")
    updated_token_hash["access_token"].should == "updated-token"
    updated_token_hash["refresh_token"].should be nil
    updated_token_hash["expiration_time"].should be nil
    updated_token_hash.should_not == token_hash
  end

  it "should be able to store additional 'hashified' app_data with tokens" do
    User::Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                             "some-token", 1, :app_data => {foo: "baz"})
    token_hash = User::Oauth2Data.get("test-user", "test-app")
    token_hash["app_data"].should == {foo: "baz"}
  end

  it "should be able to handle a malformed app_data entry" do
    suppress_rails_logging do
      User::Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                               "some-token", 1, :app_data => "foo")
    end
    token_hash = User::Oauth2Data.get("test-user", "test-app")
    token_hash["app_data"].should be_empty
  end

  it "should be able to get and update google email for authenticated users" do
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    User::Oauth2Data.get_google_email(@random_id).blank?.should be_true
    GoogleApps::Userinfo.any_instance.stub(:user_info).and_return(@fake_google_userinfo)
    User::Oauth2Data.update_google_email!(@random_id)
    User::Oauth2Data.get_google_email(@random_id).should == "tammi.chang.clc@gmail.com"
  end

  it "should fail updating canvas email on a non-existant Canvas account" do
    Canvas::UserProfile.any_instance.stub(:user_profile).and_return(@canvas_404)
    User::Oauth2Data.new_or_update(@random_id, Canvas::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    User::Oauth2Data.get_canvas_email(@random_id).blank?.should be_true
    User::Oauth2Data.update_canvas_email!(@random_id)
    User::Oauth2Data.get_canvas_email(@random_id).blank?.should be_true
  end

  it "should successfully update a canvas email " do
    Canvas::UserProfile.stub(:new).and_return(@fake_canvas_user_profile)
    User::Oauth2Data.new_or_update(@random_id, Canvas::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    User::Oauth2Data.get_canvas_email(@random_id).blank?.should be_true
    User::Oauth2Data.update_canvas_email!(@random_id)
    User::Oauth2Data.get_canvas_email(@random_id).blank?.should be_false
  end

  it "should simulate a non-responsive google", :testext => true do
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleApps::Userinfo.stub(:new).and_return(@real_google_userinfo)
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    User::Oauth2Data.any_instance.should_not_receive(:save)
    User::Oauth2Data.update_google_email!(@random_id)
  end

  it "should invalidate cache when tokens are deleted" do
    oauth2 = User::Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    Cache::UserCacheExpiry.should_receive(:notify).exactly(2).times
    oauth2.save.should be_true
    User::Oauth2Data.destroy_all(:uid => "test-user", :app_id => "test-app")
    access_token = User::Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should be_nil
  end

  it "should remove dismiss_reminder app_data when a new google token is stored" do
    User::Oauth2Data.dismiss_google_reminder(@random_id).should be_true
    User::Oauth2Data.is_google_reminder_dismissed(@random_id).should be_true
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, 'top', 'secret')
    User::Oauth2Data.is_google_reminder_dismissed(@random_id).should be_empty
  end

  it "new_or_update should merge new app_data into existing app_data" do
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, 'top', 'secret', 0, {app_data:{'foo' => 'foo?'}})
    User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, @random_id, 'foo' ).should == 'foo?'
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, 'top', 'secret', 0, {app_data:{'baz' => 'baz!'}})
    User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, @random_id, 'baz' ).should == 'baz!'
    User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, @random_id, 'foo' ).should == 'foo?'
  end

end
