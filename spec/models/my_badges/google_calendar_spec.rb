require "spec_helper"

describe "MyBadges" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_drive_list = GoogleDriveListProxy.new(:fake => true)
    @fake_events_list = GoogleEventsListProxy.new(:fake => true)
  end

  it "OskiBear should have two calendar events needing a response" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleDriveListProxy.stub(:new).and_return(@fake_drive_list)
    GoogleEventsListProxy.stub(:new).and_return(@fake_events_list)
    Oauth2Data.stub(:get_google_email).and_return("oski.bear.clc@gmail.com")

    unread = MyBadges::GoogleCalendar.new @user_id
    unread.fetch_counts.should == 2
  end
end
