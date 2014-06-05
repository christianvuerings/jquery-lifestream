require "spec_helper"

describe "MyAcademics::Regblocks" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_blocks_proxy = Bearfacts::Regblocks.new({:user_id => "61889", :fake => true})
    Bearfacts::Regblocks.stub(:new).and_return(oski_blocks_proxy)

    feed = {}
    MyAcademics::Regblocks.new("61889").merge(feed)
    feed.empty?.should be_false

    oski_blocks = feed[:regblocks]
    oski_blocks[:errored].should be_false
    oski_blocks[:activeBlocks].empty?.should be_false
    oski_blocks[:activeBlocks].each do |block|
      block[:status].should == "Active"
      block[:type].should_not be_nil
    end

    oski_blocks[:inactiveBlocks].empty?.should be_false
    oski_blocks[:inactiveBlocks].each do |block|
      block[:status].should == "Released"
      block[:type].should_not be_nil
    end

    # Make sure the date epoch matches the expected date.
    Time.at(oski_blocks[:inactiveBlocks][1][:blockedDate][:epoch]).to_s.start_with?('2012-03-20').should be_true

  end

  context "Offline BearfactsApi for regblocks" do
    before(:each) { stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Faraday::Error::ConnectionFailed) }

    subject do
      feed = {}
      MyAcademics::Regblocks.new("61889").merge(feed)
      feed[:regblocks]
    end

    it "should be offline with empty blocks" do
      subject[:errored].should be_true
      %w(activeBlocks inactiveBlocks).each { |key| subject[key.to_sym].should be_blank }
    end
  end

end
