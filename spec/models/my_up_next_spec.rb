require "spec_helper"

describe "MyUpNext" do
  before(:each) do
    @user_id = rand(99999).to_s
    @fake_google_proxy = GoogleProxy.new({fake: true})
    @fake_google_events_array = @fake_google_proxy.events_list({:maxResults => 10})

  end

  it "should load nicely with the pre-recorded fake Google proxy feed for event#list" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleProxy.stub(:new).and_return(@fake_google_proxy)
    GoogleProxy.any_instance.stub(:events_list).and_return(@fake_google_events_array)
    valid_feed = MyUpNext.get_feed(@user_id)
    valid_feed["items"].size.should == 13
    valid_feed["items"].each do |entry|
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
    GoogleProxy.any_instance.stub(:events_list).and_return(@fake_google_events_array)
    empty_feed = MyUpNext.get_feed(@user_id)
    empty_feed["items"].empty?.should be_true
  end

end