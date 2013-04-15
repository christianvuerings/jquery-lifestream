require "spec_helper"

describe "MyRegBlocks" do

  it "should get properly formatted registration blocks from fake Bearfacts" do
    oski_bearfacts_proxy = BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true})
    BearfactsRegblocksProxy.stub(:new).and_return(oski_bearfacts_proxy)
    oski_blocks = MyRegBlocks.new("61889").get_feed
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
