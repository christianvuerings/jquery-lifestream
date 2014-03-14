require "spec_helper"

describe UpNext::MyUpNext do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = Google::EventsList.new({fake: true})
    @real_events_list = Google::EventsList.new(
      :access_token => Settings.google_proxy.test_user_access_token,
      :refresh_token => Settings.google_proxy.test_user_refresh_token,
      :expiration_time => 0
    )
  end

  it "should load nicely with the pre-recorded fake Google proxy feed for event#list" do
    Google::Proxy.stub(:access_granted?).and_return(true)
    Google::EventsList.stub(:new).and_return(@fake_google_proxy)
    fake_google_events_array = @fake_google_proxy.events_list({:maxResults => 10})
    Google::EventsList.any_instance.stub(:events_list).and_return(fake_google_events_array)
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
  end

  it "should return an empty feed for non-authorized users" do
    Google::Proxy.stub(:new).and_return(@fake_google_proxy)
    Google::Proxy.stub(:access_granted?).and_return(false)
    empty_feed = UpNext::MyUpNext.new(@user_id).get_feed
    empty_feed[:items].empty?.should be_true
  end

  it "should return an empty feed for act-as users" do
    Google::Proxy.stub(:new).and_return(@fake_google_proxy)
    Google::Proxy.stub(:access_granted?).and_return(true)
    another_user = @user_id
    while (another_user == @user_id)
      another_user = rand(99999).to_s
    end
    empty_feed = UpNext::MyUpNext.new(@user_id, :original_user_id => another_user).get_feed
    empty_feed[:items].empty?.should be_true
  end

  it "should not include all-day events for tomorrow" do
    too_late = Time.zone.today.to_time_in_current_zone.to_datetime.end_of_day
    Google::Proxy.stub(:access_granted?).and_return(true)
    Google::Proxy.stub(:new).and_return(@fake_google_proxy)
    valid_feed = UpNext::MyUpNext.new(@user_id).get_feed
    valid_feed[:items].size.should be > 0
    out_of_scope_items = valid_feed[:items].select { |entry|
      entry[:is_all_day] && DateTime.parse(entry[:start][:date_time]) >= too_late
    }
    out_of_scope_items.size.should == 0
  end

  it "should simulate a non-responsive google", :testext => true do
    Google::Proxy.stub(:access_granted?).and_return(true)
    Google::APIClient.any_instance.stub(:execute).and_raise(StandardError)
    Google::APIClient.stub(:execute).and_raise(StandardError)
    Google::EventsList.stub(:new).and_return(@real_events_list)
    dead_feed = UpNext::MyUpNext.new @user_id
    dead_feed.get_feed[:items].should == []
  end

  context "cache expiration" do
    before(:each){ @instance = UpNext::MyUpNext.new(@user_id) }
    it "should expire tomorrow at midnight" do
      midnight_tomorrow = Time.zone.today.to_time_in_current_zone.advance(:days=>1).at_midnight.to_i
      @instance.class.expires_in.should == midnight_tomorrow
    end
  end

end
