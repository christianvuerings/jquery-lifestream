require "spec_helper"

describe "UserVisit" do

  before do
    @user_id = rand(9999999).to_s
  end

  it "should record a user's visit time twice" do
    UserVisit.record @user_id
    UserVisit.record @user_id

    saved = UserVisit.where(:user_id => @user_id)
    saved.should_not be_nil
  end

end
