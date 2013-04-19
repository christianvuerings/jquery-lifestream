require "spec_helper"

describe "MyBadges::bMail" do
  before(:each) do
    @user_id = rand(999999).to_s
    @fake_mail_list = GoogleMailListProxy.new(:fake => true)
  end

  it "OskiBear should have three unread bMail messages" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)

    unread = MyBadges::GoogleMail.new @user_id
    unread.fetch_counts[:count].should == 3
  end

  it "Unauthenticated users should have zero unread bMail messages" do
    # Intentionally not authenticating before asking for MyBadges
    GoogleProxy.stub(:access_granted?).and_return(false)
    merged = MyBadges::Merged.new @user_id
    unread = merged.get_feed
    unread[:badges].each do |k,v|
      unread[:badges][k][:count].should == 0
      unread[:badges][k][:items].empty?.should be_true
    end
  end

  it "Nokogiri parse failures should raise an exception" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)
    Nokogiri::XML.stub(:parse).and_raise(StandardError)

    results = MyBadges::GoogleMail.new(@user_id).fetch_counts
    results[:count].should == 0
  end

  it "should handle bad data on xml fields" do
    GoogleProxy.stub(:access_granted?).and_return(true)
    GoogleMailListProxy.stub(:new).and_return(@fake_mail_list)
    Nokogiri::XML::Document.any_instance.stub(:search).with('fullcount').and_return(%w(potato))
    suppress_rails_logging {
      results = MyBadges::GoogleMail.new(@user_id).fetch_counts
      results[:count].should == 0
    }
    Nokogiri::XML::Document.any_instance.stub(:search).and_return(%w(multi element bogus result))
    suppress_rails_logging {
      results = MyBadges::GoogleMail.new(@user_id).fetch_counts
      results[:items].size.should == 0
    }
    Nokogiri::XML::Document.any_instance.unstub(:search)
    Nokogiri::XML::NodeSet.any_instance.stub(:search).and_return(nil)
    suppress_rails_logging {
      results = MyBadges::GoogleMail.new(@user_id).fetch_counts
      results[:items].size.should == 0
    }
    Nokogiri::XML::NodeSet.any_instance.unstub(:search)
    DateTime.stub(:iso8601).and_raise(StandardError)
    suppress_rails_logging {
      results = MyBadges::GoogleMail.new(@user_id).fetch_counts
      results[:items].size.should == 0
    }

  end


end
