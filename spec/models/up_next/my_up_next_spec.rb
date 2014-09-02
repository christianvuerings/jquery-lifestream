require "spec_helper"

describe UpNext::MyUpNext do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = GoogleApps::EventsList.new({fake: true})
    @real_events_list = GoogleApps::EventsList.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
  end

  it "should load nicely with the pre-recorded fake Google proxy feed for event#list" do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::EventsList.stub(:new).and_return(@fake_google_proxy)
    fake_google_events_array = @fake_google_proxy.events_list({:maxResults => 10})
    GoogleApps::EventsList.any_instance.stub(:events_list).and_return(fake_google_events_array)
    valid_feed = UpNext::MyUpNext.new(@user_id).get_feed
    valid_feed[:items].size.should == 13
    valid_feed[:items].each do |entry|
      entry[:status].should_not == "cancelled"
      if !entry[:start].blank?
        entry[:start][:epoch].is_a?(Integer).should be true
        entry[:start][:epoch].should > Time.new(1970, 1, 1).to_i
      end
      if !entry[:end].blank?
        entry[:end][:epoch].is_a?(Integer).should be true
        entry[:end][:epoch].should > Time.new(1970, 1, 1).to_i
      end
    end
    valid_feed[:date].should be_present
    valid_feed[:date][:epoch].should > Time.new(1970, 1, 1).to_i
  end

  it "should return an empty feed for non-authorized users" do
    GoogleApps::Proxy.stub(:new).and_return(@fake_google_proxy)
    GoogleApps::Proxy.stub(:access_granted?).and_return(false)
    empty_feed = UpNext::MyUpNext.new(@user_id).get_feed
    empty_feed[:items].empty?.should be_true
  end

  it "should not include all-day events for tomorrow" do
    too_late = Time.zone.today.in_time_zone.to_datetime.end_of_day
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    GoogleApps::Proxy.stub(:new).and_return(@fake_google_proxy)
    valid_feed = UpNext::MyUpNext.new(@user_id).get_feed
    valid_feed[:items].size.should be > 0
    out_of_scope_items = valid_feed[:items].select { |entry|
      entry[:isAllDay] && DateTime.parse(entry[:start][:dateTime]) >= too_late
    }
    out_of_scope_items.size.should == 0
  end

  it "should simulate a non-responsive google", :testext => true do
    GoogleApps::Proxy.stub(:access_granted?).and_return(true)
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    GoogleApps::EventsList.stub(:new).and_return(@real_events_list)
    dead_feed = UpNext::MyUpNext.new(@user_id).get_feed
    dead_feed[:items].should == []
    dead_feed[:date].should be_present
    dead_feed[:date][:epoch].should > Time.new(1970, 1, 1).to_i
  end

end
