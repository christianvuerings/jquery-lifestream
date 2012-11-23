require "spec_helper"

describe Oauth2Data do

  it "should not store plaintext access tokens" do
    Oauth2Data.any_instance.stub(:decrypt_tokens).and_return(nil)
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    oauth2.save.should be_true
    access_token = Oauth2Data.get_access_token("test-user", "test-app")
    access_token.should_not == "test-token"
  end

  it "should return decrypted access tokens" do
    oauth2 = Oauth2Data.new(uid: "test-user", app_id: "test-app", access_token: "test-token")
    oauth2.save.should be_true
    access_token = Oauth2Data.get_access_token("test-user", "test-app")
    access_token.should == "test-token"
  end

end
