require "spec_helper"

describe Oauth2Data do

  it "should not store plaintext access tokens" do
    Oauth2Data.any_instance.stub(:decrypt_tokens).and_return(nil)
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    oauth2.save.should be_true
    access_token = Oauth2Data.get("test-user", "test-app")["access_token"]
    access_token.should_not == "test-token"
  end

  it "should return decrypted access tokens" do
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
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
    Oauth2Data.new_or_update("test-user", "test-app", "updated-token")
    updated_token_hash = Oauth2Data.get("test-user", "test-app")
    updated_token_hash["access_token"].should == "updated-token"
    updated_token_hash["refresh_token"].should be nil
    updated_token_hash["expiration_time"].should be nil
    updated_token_hash.should_not == token_hash
  end

end
