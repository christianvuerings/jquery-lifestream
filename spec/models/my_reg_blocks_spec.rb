require 'spec_helper'

describe MyRegBlocks do
  let! (:oski_blocks_proxy) { BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true}) }
  before { BearfactsRegblocksProxy.stub(:new).and_return(oski_blocks_proxy) }
  subject { MyRegBlocks.new(61889).get_feed }

  it "should return some regblocks for oski" do
    subject[:active_blocks].empty?.should be_false
    subject[:active_blocks].each do |block|
      block[:status].should == "Active"
      block[:type].should_not be_nil
    end
    subject[:inactive_blocks].empty?.should be_false
    subject[:inactive_blocks].each do |block|
      block[:status].should == "Released"
      block[:type].should_not be_nil
    end
  end
end
