describe "User::Visit" do

  before do
    @user_id = rand(9999999).to_s
  end

  it "should record a user's visit time twice" do
    User::Visit.record @user_id
    User::Visit.record @user_id

    saved = User::Visit.where(:user_id => @user_id)
    saved.should_not be_nil
  end

end
