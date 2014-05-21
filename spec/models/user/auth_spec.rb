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
    policy = User::Auth.get(@user_id).policy
    policy.can_administrate?.should be_true
    policy.can_clear_cache?.should be_true
    policy.can_clear_campus_links_cache?.should be_true
    policy.can_administrate_globally?.should be_true
    policy.can_refresh_log_settings?.should be_true
    policy.can_act_as?.should be_true
    policy.can_author?.should be_true
  end

  it "anonymous user should have no permissions but still be active" do
    anon = User::Auth.get nil
    anon.is_superuser?.should be_false
    anon.is_test_user?.should be_false
    anon.is_author?.should be_false
    anon.is_viewer?.should be_false
    anon.active?.should be_true
  end

  it "anonymous user should have a very restrictive policy" do
    anon = User::Auth.get 0
    policy = anon.policy
    policy.can_clear_cache?.should be_false
    policy.can_clear_campus_links_cache?.should be_false
    policy.can_administrate_globally?.should be_false
    policy.can_refresh_log_settings?.should be_false
    policy.can_act_as?.should be_false
    policy.can_author?.should be_false
  end

  it "a deactivated superuser should have no rights" do
    User::Auth.new_or_update_superuser!(@user_id)
    user = User::Auth.get(@user_id)
    user.is_superuser?.should be_true
    user.active = false
    user.save

    policy = User::Auth.get(@user_id).policy
    policy.can_administrate?.should be_false
    policy.can_clear_cache?.should be_false
    policy.can_clear_campus_links_cache?.should be_false
    policy.can_administrate_globally?.should be_false
    policy.can_refresh_log_settings?.should be_false
    policy.can_act_as?.should be_false
    policy.can_author?.should be_false
  end

end
