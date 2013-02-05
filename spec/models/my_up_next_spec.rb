require "spec_helper"

describe "MyUpNext" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = GoogleEventsListProxy.new({fake: true})

  end

  it "should load nicely with the pre-recorded fake Google proxy feed for event#list" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleEventsListProxy.stub(:new).and_return(@fake_google_proxy)
    fake_google_events_array = @fake_google_proxy.events_list({:maxResults => 10})
    GoogleEventsListProxy.any_instance.stub(:events_list).and_return(fake_google_events_array)
    valid_feed = MyUpNext.new(@user_id).get_feed
    valid_feed[:items].size.should == 13
    valid_feed[:items].each do |entry|
      entry["status"].should_not == "cancelled"
      if !entry["start"].blank?
        entry["start"]["epoch"].is_a?(Integer).should be true
        entry["start"]["epoch"].should > Time.new(1970, 1, 1).to_i
      end
      if !entry["end"].blank?
        entry["end"]["epoch"].is_a?(Integer).should be true
        entry["end"]["epoch"].should > Time.new(1970, 1, 1).to_i
      end
      entry["id"].should_not be blank?
    end
  end

  it "should return an empty feed for non-authorized users" do
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    empty_feed = MyUpNext.new(@user_id).get_feed
    empty_feed["items"].empty?.should be_true
  end

  it "should not include all-day events for tomorrow" do
    too_late = Date.today.to_time_in_current_zone.to_datetime.end_of_day
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    GoogleProxy.any_instance.stub(:events_list).and_return(@fake_google_events_array)
    valid_feed = MyUpNext.new(@user_id).get_feed
    valid_feed[:items].size.should be > 0
    all_day_event_count = 0
    valid_feed[:items].each do |entry|
      DateTime.parse(entry["start"]["datetime"]).should be < too_late
      all_day_event_count += 1 if entry["is_all_day"] === true
    end
    all_day_event_count.should be > 0
  end

end
