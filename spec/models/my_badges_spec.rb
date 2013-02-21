require "spec_helper"

describe "MyBadges" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_drive_list = GoogleDriveListProxy.new(:fake => true)
  end

  it "should be able to filter out entries older than 6 months" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
    badges = MyBadges::Merged.new @user_id
    filtered_feed =  badges.get_feed
    filtered_feed["unread_badge_counts"].empty?.should_not be_true
    filtered_feed["unread_badge_counts"]["bdrive"].should == 1
    MyBadges::GoogleDrive.any_instance.stub(:is_recent_message?).and_return(true)
    badges.expire_cache
    badges = MyBadges::Merged.new @user_id
    mangled_feed = badges.get_feed
    mangled_feed["unread_badge_counts"].empty?.should_not be_true
    mangled_feed["unread_badge_counts"]["bdrive"].should == 2
  end

  it "should be able to ignore entries with malformed fields" do
    default_logger = Rails.logger
    Rails.logger = Logger.new("/dev/null")
    begin
      GoogleProxy.stub(:access_granted?).and_return(true)
      GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
      MyBadges::GoogleDrive.any_instance.stub(:is_unread_message?).and_raise(ArgumentError, "foo")
      badges = MyBadges::Merged.new @user_id
      filtered_feed =  badges.get_feed
      filtered_feed["unread_badge_counts"].empty?.should_not be_true
      filtered_feed["unread_badge_counts"].each do |key, value|
        value.should == 0
      end
    ensure
      Rails.logger = default_logger
    end
  end
end