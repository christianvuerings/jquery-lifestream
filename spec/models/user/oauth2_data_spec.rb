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
    @fake_canvas_user_profile = Canvas::SisUserProfile.new(fake: true, user_id: 300846)
  end

  it "should not store plaintext access tokens" do
    allow_any_instance_of(User::Oauth2Data).to receive(:decrypt_tokens).and_return(nil)
    oauth2 = User::Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    expect(oauth2.save).to be_truthy
    access_token = User::Oauth2Data.get("test-user", "test-app")["access_token"]
    expect(access_token).to_not eq "test-token"
  end

  it "should return decrypted access tokens" do
    oauth2 = User::Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    expect(Cache::UserCacheExpiry).to receive(:notify).once
    expect(oauth2.save).to be_truthy
    access_token = User::Oauth2Data.get("test-user", "test-app")["access_token"]
    expect(access_token).to eq "test-token"
  end

  it "should be able to update existing tokens" do
    User::Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                                      "some-token", 1)
    token_hash = User::Oauth2Data.get("test-user", "test-app")
    expect(token_hash["access_token"]).to eq "new-token"
    expect(token_hash["refresh_token"]).to eq "some-token"
    expect(token_hash["expiration_time"]).to eq 1
    expect(Cache::UserCacheExpiry).to receive(:notify).once
    User::Oauth2Data.new_or_update("test-user", "test-app", "updated-token")
    updated_token_hash = User::Oauth2Data.get("test-user", "test-app")
    expect(updated_token_hash["access_token"]).to eq "updated-token"
    expect(updated_token_hash["refresh_token"]).to be_nil
    expect(updated_token_hash["expiration_time"]).to be_nil
    expect(updated_token_hash).to_not eq token_hash
  end

  it "should be able to store additional 'hashified' app_data with tokens" do
    User::Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                             "some-token", 1, :app_data => {foo: "baz"})
    token_hash = User::Oauth2Data.get("test-user", "test-app")
    expect(token_hash["app_data"]).to eq({:foo => "baz"})
  end

  it "should be able to handle a malformed app_data entry" do
    suppress_rails_logging do
      User::Oauth2Data.new_or_update("test-user", "test-app", "new-token",
                               "some-token", 1, :app_data => "foo")
    end
    token_hash = User::Oauth2Data.get("test-user", "test-app")
    expect(token_hash["app_data"]).to be_empty
  end

  it "should be able to get and update google email for authenticated users" do
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    User::Oauth2Data.get_google_email(@random_id).blank?.should be_truthy
    allow_any_instance_of(GoogleApps::Userinfo).to receive(:user_info).and_return(@fake_google_userinfo)
    User::Oauth2Data.update_google_email!(@random_id)
    expect(User::Oauth2Data.get_google_email(@random_id)).to eq "tammi.chang.clc@gmail.com"
  end

  it "should fail updating canvas email on a non-existant Canvas account" do
    allow_any_instance_of(Canvas::SisUserProfile).to receive(:sis_user_profile).and_return(statusCode: 404, error: [{message: 'Resource not found.'}])
    User::Oauth2Data.new_or_update(@random_id, Canvas::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    User::Oauth2Data.get_canvas_email(@random_id).blank?.should be_truthy
    User::Oauth2Data.update_canvas_email!(@random_id)
    User::Oauth2Data.get_canvas_email(@random_id).blank?.should be_truthy
  end

  it "should successfully update a canvas email " do
    allow(Canvas::SisUserProfile).to receive(:new).and_return(@fake_canvas_user_profile)
    User::Oauth2Data.new_or_update(@random_id, Canvas::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    expect(User::Oauth2Data.get_canvas_email(@random_id).blank?).to be_truthy
    User::Oauth2Data.update_canvas_email!(@random_id)
    expect(User::Oauth2Data.get_canvas_email(@random_id).blank?).to be_falsey
  end

  it "should simulate a non-responsive google", :testext => true do
    allow_any_instance_of(Google::APIClient).to receive(:execute).and_raise(StandardError)
    allow(Google::APIClient).to receive(:execute).and_raise(StandardError)
    allow(GoogleApps::Userinfo).to receive(:new).and_return(@real_google_userinfo)
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, "new-token",
                             "some-token", 1)
    expect_any_instance_of(User::Oauth2Data).to_not receive(:save)
    User::Oauth2Data.update_google_email!(@random_id)
  end

  it "should invalidate cache when tokens are deleted" do
    oauth2 = User::Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    expect(Cache::UserCacheExpiry).to receive(:notify).exactly(2).times
    expect(oauth2.save).to be_truthy
    User::Oauth2Data.destroy_all(:uid => "test-user", :app_id => "test-app")
    access_token = User::Oauth2Data.get("test-user", "test-app")["access_token"]
    expect(access_token).to be_nil
  end

  it "should remove dismiss_reminder app_data when a new google token is stored" do
    expect(User::Oauth2Data.dismiss_google_reminder(@random_id)).to be_truthy
    expect(User::Oauth2Data.is_google_reminder_dismissed(@random_id)).to be_truthy
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, 'top', 'secret')
    expect(User::Oauth2Data.is_google_reminder_dismissed(@random_id)).to be_empty
  end

  it "new_or_update should merge new app_data into existing app_data" do
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, 'top', 'secret', 0, {app_data:{'foo' => 'foo?'}})
    expect(User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, @random_id, 'foo' )).to eq 'foo?'
    User::Oauth2Data.new_or_update(@random_id, GoogleApps::Proxy::APP_ID, 'top', 'secret', 0, {app_data:{'baz' => 'baz!'}})
    expect(User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, @random_id, 'baz' )).to eq 'baz!'
    expect(User::Oauth2Data.send(:get_appdata_field, GoogleApps::Proxy::APP_ID, @random_id, 'foo' )).to eq 'foo?'
  end

end
