require "spec_helper"

describe "MyBadges" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_drive_list = GoogleDriveListProxy.new(:fake => true, :fake_options => {:match_requests_on => [:method, :path]})
    @fake_events_list = GoogleEventsListProxy.new(:fake => true, :fake_options => {:match_requests_on => [:method, :path]})
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
    filtered_feed[:badges].empty?.should_not be_true
    filtered_feed[:badges]["bdrive"][:count].should == 4
    MyBadges::GoogleDrive.any_instance.stub(:is_recent_message?).and_return(true)
    badges.expire_cache
    MyBadges::GoogleDrive.expire @user_id
    badges = MyBadges::Merged.new @user_id
    mangled_feed = badges.get_feed
    mangled_feed[:badges].empty?.should_not be_true
    mangled_feed[:badges]["bdrive"][:count].should == 10
    mangled_feed[:badges]["bdrive"][:items].size.should == 5
    mangled_feed[:badges]["bcal"][:count].should == 6
    mangled_feed[:badges]["bcal"][:items].size.should == 5
    mangled_feed[:badges]["bcal"][:items].select { |entry|
      entry[:all_day_event]
    }.size.should == 1
    mangled_feed[:badges]["bcal"][:items].select { |entry|
      entry[:change_state] if entry[:change_state] == "new"
    }.size.should == 1
  end

  it "should be able to ignore entries with malformed fields" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
    GoogleEventsListProxy.stub(:new).and_return(@fake_events_list)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)
    MyBadges::GoogleDrive.any_instance.stub(:is_recent_message?).and_raise(ArgumentError, "foo")
    MyBadges::GoogleCalendar.any_instance.stub(:verify_and_format_date).and_raise(ArgumentError, "foo")
    badges = MyBadges::Merged.new @user_id
    suppress_rails_logging {
      filtered_feed =  badges.get_feed
      filtered_feed[:badges].empty?.should_not be_true
      filtered_feed[:badges].each do |key, value|
        if key == "bmail"
          value[:count].should_not == 0
        else
          value[:count].should == 0
        end
      end
    }
  end

  it "should have contain some of the same common item-keys across the different badge endpoints" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
    GoogleEventsListProxy.stub(:new).and_return(@fake_events_list)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)
    badges_feed = MyBadges::Merged.new(@user_id).get_feed[:badges]

    badges_feed.each do |source_key, source_value|
      source_value[:count].blank?.should_not be_true
      source_value[:items].kind_of?(Enumerable).should be_true
      source_value[:items].each do |feed_items|
        if %w(bcal bdrive).include? source_key
          feed_items[:change_state].blank?.should_not be_true
        end
        if source_key == "bcal"
          %w(start_time end_time).each do |required_key|
            feed_items[required_key.to_sym].blank?.should_not be_true
          end
          if feed_items[:change_state] == "new"
            feed_items[:editor].blank?.should_not be_true
          end
        end
        if source_key != "bcal"
          feed_items[:editor].blank?.should_not be_true
        end
        %w(title modified_time link).each do |required_key|
          feed_items[required_key.to_sym].blank?.should_not be_true
        end
      end
    end
  end

  it "should simulate a non-responsive google", :testext => true do
    GoogleProxy.stub(:access_granted?).and_return(true)
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleDriveListProxy.stub(:new).and_return(@real_drive_list)
    badges = MyBadges::Merged.new @user_id
    badges.get_feed[:badges].each do |key, value|
      value[:count].should == 0
    end
  end

end
