require "spec_helper"

describe "User::Auth" do
  before do
    Rails.env.stub(:production?).and_return(true)
    @user_id = rand(99999).to_s
  end

  it "should not be a superuser by default" do
    User::Auth.get(@user_id).is_superuser.should be_false
  end

  it "should have superuser when given permission" do
    User::Auth.new_or_update_superuser!(@user_id)
    User::Auth.get(@user_id).is_superuser.should be_true
  end

  it "anonymous user should have no permissions but still be active" do
    anon = User::Auth.get nil
    anon.is_superuser?.should be_false
    anon.is_author?.should be_false
    anon.is_viewer?.should be_false
    anon.active?.should be_true
  end

end
