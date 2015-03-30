require "spec_helper"

describe "MyBadges" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_drive_list = GoogleApps::DriveList.new(:fake => true)
    @fake_events_list = GoogleApps::EventsRecentItems.new(:fake => true)
    @fake_mail_list = GoogleApps::MailList.new(:fake => true)
    @real_drive_list = GoogleApps::DriveList.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
  end

  it "should be able to filter out entries older than one month" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::DriveList.stub(:new).and_return(@fake_drive_list)
    GoogleApps::EventsRecentItems.stub(:new).and_return(@fake_events_list)
    User::Oauth2Data.stub(:get_google_email).and_return("tammi.chang.clc@gmail.com")
    badges = MyBadges::Merged.new @user_id
    filtered_feed = badges.get_feed
    filtered_feed[:badges].empty?.should_not be_truthy
    filtered_feed[:badges]["bdrive"][:count].should == 4
    MyBadges::GoogleDrive.any_instance.stub(:is_recent_message?).and_return(true)
    badges.expire_cache
    MyBadges::GoogleDrive.expire @user_id
    badges = MyBadges::Merged.new @user_id
    mangled_feed = badges.get_feed
    mangled_feed[:badges].empty?.should_not be_truthy
    mangled_feed[:badges]["bdrive"][:count].should == 10
    mangled_feed[:badges]["bdrive"][:items].size.should == 10
    mangled_feed[:badges]["bcal"][:count].should == 6
    mangled_feed[:badges]["bcal"][:items].size.should == 6
    mangled_feed[:badges]["bcal"][:items].select { |entry|
      entry[:allDayEvent]
    }.size.should == 1
    mangled_feed[:badges]["bcal"][:items].select { |entry|
      entry[:changeState] if entry[:changeState] == "new"
    }.size.should == 1
    mangled_feed[:badges]["bcal"][:items].select { |entry|
      entry[:changeState] if entry[:changeState] == "created"
    }.size.should == 1
  end

  it "should be able to ignore entries with malformed fields" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::DriveList.stub(:new).and_return(@fake_drive_list)
    GoogleApps::EventsRecentItems.stub(:new).and_return(@fake_events_list)
    GoogleApps::MailList.stub(:new).and_return(@fake_mail_list)
    MyBadges::GoogleDrive.any_instance.stub(:is_recent_message?).and_raise(ArgumentError, "foo")
    MyBadges::GoogleCalendar.any_instance.stub(:verify_and_format_date).and_raise(ArgumentError, "foo")
    badges = MyBadges::Merged.new @user_id
    suppress_rails_logging {
      filtered_feed =  badges.get_feed
      filtered_feed[:badges].empty?.should_not be_truthy
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
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::DriveList.stub(:new).and_return(@fake_drive_list)
    GoogleApps::EventsRecentItems.stub(:new).and_return(@fake_events_list)
    GoogleApps::MailList.stub(:new).and_return(@fake_mail_list)
    badges_feed = MyBadges::Merged.new(@user_id).get_feed[:badges]

    badges_feed.each do |source_key, source_value|
      source_value[:count].blank?.should_not be_truthy
      source_value[:items].kind_of?(Enumerable).should be_truthy
      source_value[:items].each do |feed_items|
        if %w(bcal bdrive).include? source_key
          feed_items[:changeState].blank?.should_not be_truthy
        end
        if source_key == "bcal"
          %w(startTime endTime).each do |required_key|
            feed_items[required_key.to_sym].blank?.should_not be_truthy
          end
          if feed_items[:changeState] == "new"
            feed_items[:editor].blank?.should_not be_truthy
          end
        end
        if source_key != "bcal"
          feed_items[:editor].blank?.should_not be_truthy
        end
        %w(title modifiedTime link).each do |required_key|
          feed_items[required_key.to_sym].blank?.should_not be_truthy
        end
      end
    end
  end

  it "should simulate a non-responsive google", :testext => true do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleApps::DriveList.stub(:new).and_return(@real_drive_list)
    badges = MyBadges::Merged.new @user_id
    badges.get_feed[:badges].each do |key, value|
      value[:count].should == 0
    end
  end

  it 'should return no badges when not authenticated' do
    allow(GoogleApps::Proxy).to receive(:access_granted?).and_return(false)
    badges = MyBadges::Merged.new(@user_id).get_feed[:badges]
    expect(badges).to be_blank
  end

  context 'css classes for bdrive icons' do
    let (:proxy) { MyBadges::GoogleDrive.new(@user_id) }
    let (:icon_class_result) { proxy.send(:process_icon, image_url) }

    context 'when icon is an expected png file' do
      let (:image_url) { 'https://ssl.gstatic.com/docs/doclist/images/icon_11_document_list.png' }
      it 'should return the file basename' do
        expect(icon_class_result).to eq 'icon_11_document_list'
      end
    end

    context 'when icon is an unexpected png file' do
      let (:image_url) { 'https://ssl.gstatic.com/docs/doclist/images/icon_11_cuneiform_list.png' }
      it 'should return nothing' do
        expect(icon_class_result).to be_blank
      end
    end

    context 'when icon is not a png file' do
      let (:image_url) { 'http://www.google.com/lol_cat.gif' }
      it 'should return nothing' do
        expect(icon_class_result).to be_blank
      end
    end
  end
end
