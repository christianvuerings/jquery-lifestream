require "spec_helper"

describe "MyBadges" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_mail_list = GoogleMailListProxy.new(:fake => true)
  end

  it "OskiBear should have three unread bMail messages" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)

    unread = MyBadges::GoogleMail.new @user_id
    unread.fetch_counts.should == 3
  end

  it "Unauthenticated users should have zero unread bMail messages" do
    # Intentionally not authenticating before asking for MyBadges
    GoogleProxy.stub(:access_granted?).and_return(false)
    merged = MyBadges::Merged.new @user_id
    unread = merged.get_feed
    unread["unread_badge_counts"].each do |k,v|
      v.should == 0
    end
  end

  it "Nokogiri parse failures should raise an exception" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleMailListProxy.stub(:new).and_return("Some non-XML string")

    unread = MyBadges::GoogleMail.new @user_id
    unread.should raise_error { |error|
      error.should be_a(Exception)
    }
  end

end
