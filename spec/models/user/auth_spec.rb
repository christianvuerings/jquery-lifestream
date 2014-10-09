require "spec_helper"

describe "User::Auth" do
  before do
    Rails.env.stub(:production?).and_return(true)
    @user_id = rand(99999).to_s
  end

  it "should not be a superuser by default" do
    User::Auth.get(@user_id).is_superuser.should be_falsey
  end

  it "should have superuser when given permission" do
    User::Auth.new_or_update_superuser!(@user_id)
    User::Auth.get(@user_id).is_superuser.should be_truthy
  end

  it "anonymous user should have no permissions but still be active" do
    anon = User::Auth.get nil
    anon.is_superuser?.should be_falsey
    anon.is_author?.should be_falsey
    anon.is_viewer?.should be_falsey
    anon.active?.should be_truthy
  end

end
