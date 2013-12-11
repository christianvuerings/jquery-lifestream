require "spec_helper"

describe "MyAcademics::Regblocks" do

  it "should get properly formatted data from fake Bearfacts" do
    oski_blocks_proxy = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true})
    BearfactsRegblocksProxy.stub(:new).and_return(oski_blocks_proxy)

    feed = {}
    MyAcademics::Regblocks.new("61889").merge(feed)
    feed.empty?.should be_false

    oski_blocks = feed[:regblocks]
    oski_blocks[:active_blocks].empty?.should be_false
    oski_blocks[:active_blocks].each do |block|
      block[:status].should == "Active"
      block[:type].should_not be_nil
    end

    oski_blocks[:inactive_blocks].empty?.should be_false
    oski_blocks[:inactive_blocks].each do |block|
      block[:status].should == "Released"
      block[:type].should_not be_nil
    end

    # Make sure the date epoch matches the expected date.
    Time.at(oski_blocks[:inactive_blocks][1][:blocked_date][:epoch]).to_s.start_with?('2012-03-20').should be_true

  end

  context "Offline BearfactsApi for regblocks" do
    before { BearfactsRegblocksProxy.any_instance.stub(:get).and_return {} }

    subject do
      feed = {}
      MyAcademics::Regblocks.new("61889").merge(feed)
      feed[:regblocks]
    end

    it "should be offline with empty blocks" do
      subject[:available].should be_false
      %w(active_blocks inactive_blocks).each { |key| subject[key.to_sym].should be_empty }
    end
  end

end
