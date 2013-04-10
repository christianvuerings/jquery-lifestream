require "spec_helper"

describe "MyBadges" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_drive_list = GoogleDriveListProxy.new(:fake => true, :fake_options => {:match_requests_on => [:method, :path]})
    @fake_events_list = GoogleEventsListProxy.new(:fake => true)
    @fake_mail_list = GoogleMailListProxy.new(:fake => true)
    @real_drive_list = GoogleDriveListProxy.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
  end

  it "should be able to filter out entries older than one month" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
    GoogleEventsListProxy.stub(:new).and_return(@fake_events_list)
    badges = MyBadges::Merged.new @user_id
    filtered_feed = badges.get_feed
    filtered_feed["unread_badge_counts"].empty?.should_not be_true
    filtered_feed["unread_badge_counts"]["bdrive"].should == 1
    MyBadges::GoogleDrive.any_instance.stub(:is_recent_message?).and_return(true)
    badges.expire_cache
    MyBadges::GoogleDrive.expire @user_id
    badges = MyBadges::Merged.new @user_id
    mangled_feed = badges.get_feed
    mangled_feed["unread_badge_counts"].empty?.should_not be_true
    mangled_feed["unread_badge_counts"]["bdrive"].should == 2
  end

  it "should be able to ignore entries with malformed fields" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
    GoogleEventsListProxy.stub(:new).and_return(@fake_events_list)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)
    MyBadges::GoogleDrive.any_instance.stub(:is_unread_message?).and_raise(ArgumentError, "foo")
    badges = MyBadges::Merged.new @user_id
    suppress_rails_logging {
      filtered_feed =  badges.get_feed
      filtered_feed["unread_badge_counts"].empty?.should_not be_true
      filtered_feed["unread_badge_counts"].each do |key, value|
        if key == "bmail"
          value.should_not == 0
        else
          value.should == 0
        end
      end
    }
  end

  it "should simulate a non-responsive google", :testext => true do
    GoogleProxy.stub(:access_granted?).and_return(true)
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleDriveListProxy.stub(:new).and_return(@real_drive_list)
    badges = MyBadges::Merged.new @user_id
    badges.get_feed["unread_badge_counts"].each do |key, value|
      value.should == 0
    end
  end

end
