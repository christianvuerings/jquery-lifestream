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

  end

end
