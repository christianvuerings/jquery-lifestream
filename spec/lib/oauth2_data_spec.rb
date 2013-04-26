require "spec_helper"

describe Oauth2Data do

  before do
    @random_id = rand(999999).to_s
    @fake_google_userinfo = GoogleUserinfoProxy.new(:fake => true).user_info
    @real_google_userinfo = GoogleUserinfoProxy.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
    @canvas_404 = OpenStruct.new(
      {
        status: 404,
        body: 'while(1);{"status":"not_found","error_report_id":44351040,"message":"Thespecifiedresourcedoesnotexist."}'
      })
    @fake_canvas_user_profile = CanvasUserProfileProxy.new(fake: true, user_id: 300846)
  end

  it "should not store plaintext access tokens" do
    Oauth2Data.any_instance.stub(:decrypt_tokens).and_return(nil)
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    oauth2.save.should be_true
    access_token = Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should_not == "test-token"
  end

  it "should return decrypted access tokens" do
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).once
    oauth2.save.should be_true
    access_token = Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should == "test-token"
  end

  it "should be able to update existing tokens" do
    Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                                      "some-token", 1)
    token_hash = Oauth2Data.get("test-user", "test-app")
    token_hash["access_token"].should == "new-token"
    token_hash["refresh_token"].should == "some-token"
    token_hash["expiration_time"].should == 1
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).once
    Oauth2Data.new_or_update("test-user", "test-app", "updated-token")
    updated_token_hash = Oauth2Data.get("test-user", "test-app")
    updated_token_hash["access_token"].should == "updated-token"
    updated_token_hash["refresh_token"].should be nil
    updated_token_hash["expiration_time"].should be nil
    updated_token_hash.should_not == token_hash
  end

  it "should be able to store additional 'hashified' app_data with tokens" do
    Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                             "some-token", 1, :app_data => {foo: "baz"})
    token_hash = Oauth2Data.get("test-user", "test-app")
    token_hash["app_data"].should == {foo: "baz"}
  end

  it "should be able to handle a malformed app_data entry" do
    suppress_rails_logging do
      Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                               "some-token", 1, :app_data => "foo")
    end
    token_hash = Oauth2Data.get("test-user", "test-app")
    token_hash["app_data"].should be_empty
  end

  it "should be able to get and update google email for authenticated users" do
    Oauth2Data.new_or_update(@random_id, GoogleProxy::APP_ID, "new-token",
                             "some-token", 1)
    Oauth2Data.get_google_email(@random_id).blank?.should be_true
    GoogleUserinfoProxy.any_instance.stub(:user_info).and_return(@fake_google_userinfo)
    Oauth2Data.update_google_email!(@random_id)
    Oauth2Data.get_google_email(@random_id).should == "tammi.chang.clc@gmail.com"
  end

  it "should fail updating canvas email on a non-existant Canvas account" do
    CanvasUserProfileProxy.any_instance.stub(:user_profile).and_return(@canvas_404)
    Oauth2Data.new_or_update(@random_id, CanvasProxy::APP_ID, "new-token",
                             "some-token", 1)
    Oauth2Data.get_canvas_email(@random_id).blank?.should be_true
    Oauth2Data.update_canvas_email!(@random_id)
    Oauth2Data.get_canvas_email(@random_id).blank?.should be_true
  end

  it "should successfully update a canvas email " do
    CanvasUserProfileProxy.stub(:new).and_return(@fake_canvas_user_profile)
    Oauth2Data.new_or_update(@random_id, CanvasProxy::APP_ID, "new-token",
                             "some-token", 1)
    Oauth2Data.get_canvas_email(@random_id).blank?.should be_true
    Oauth2Data.update_canvas_email!(@random_id)
    Oauth2Data.get_canvas_email(@random_id).blank?.should be_false
  end

  it "should simulate a non-responsive google", :testext => true do
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleUserinfoProxy.stub(:new).and_return(@real_google_userinfo)
    Oauth2Data.new_or_update(@random_id, GoogleProxy::APP_ID, "new-token",
                             "some-token", 1)
    Oauth2Data.any_instance.should_not_receive(:save)
    Oauth2Data.update_google_email!(@random_id)
  end

  it "should invalidate cache when tokens are deleted" do
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    Calcentral::USER_CACHE_EXPIRATION.should_receive(:notify).exactly(2).times
    oauth2.save.should be_true
    Oauth2Data.destroy_all(:uid => "test-user", :app_id => "test-app")
    access_token = Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should be_nil
  end

end
