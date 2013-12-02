require "spec_helper"

describe "UserAuth" do
  before do
    @user_id = rand(99999).to_s
    while (@another_user_id == nil || @user_id == @another_user_id)
      @another_user_id = rand(99999).to_s
    end
  end

  it "should not be a superuser by default" do
    UserAuth.is_superuser?(@user_id).should be_false
  end

  it "should have superuser when given permission" do
    UserAuth.new_or_update_superuser!(@user_id)
    UserAuth.is_superuser?(@user_id).should be_true
  end
end
