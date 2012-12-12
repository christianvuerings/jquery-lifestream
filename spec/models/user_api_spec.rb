require "spec_helper"

describe "UserApi" do
  before(:each) do
    @random_id = Time.now.to_f.to_s.gsub(".", "")
    @default_name = "Joe Default"
    CampusData.stub(:get_person_attributes) do |uid|
      if uid == @random_id
        {'person_name' => @default_name}
      else
        {}
      end
    end
  end

  it "should find user with default name" do
    u = UserApi.new(@random_id)
    u.preferred_name.should == @default_name
  end
  it "should override the default name" do
    u = UserApi.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = UserApi.new(@random_id)
    u.preferred_name.should == "Herr Heyer"
  end
  it "should revert to the default name" do
    u = UserApi.new(@random_id)
    u.update_attributes(preferred_name: "Herr Heyer")
    u = UserApi.new(@random_id)
    u.update_attributes(preferred_name: "")
    u = UserApi.new(@random_id)
    u.preferred_name.should == @default_name
  end
  it "should return a user data structure" do
    user_data = UserApi.new(@random_id).get_feed
    user_data[:preferred_name].should == @default_name
    user_data[:has_canvas_access_token].should_not be_nil
  end
  it "should return whether Canvas access is granted" do
    CanvasProxy.stub(:access_granted?).and_return(true, false)
    user_data = UserApi.new(@random_id).get_feed
    user_data[:has_canvas_access_token].should be_true
    # Our cache invalidation code won't be designed to handle service
    # stub changes, and so we clear the cache explicitly before
    # re-requesting the user status feed.
    Rails.cache.clear
    user_data = UserApi.new(@random_id).get_feed
    user_data[:has_canvas_access_token].should be_false
  end
  it "should have a null first_login time for a new user" do
    user_data = UserApi.new(@random_id).get_feed
    user_data[:first_login_at].should be_nil
  end
  it "should properly register a call to record_first_login" do
    user_api = UserApi.new(@random_id)
    user_api.get_feed
    user_api.record_first_login
    updated_data = user_api.get_feed
    updated_data[:first_login_at].should_not be_nil
  end
end