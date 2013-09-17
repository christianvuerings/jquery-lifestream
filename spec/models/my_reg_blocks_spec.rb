require 'spec_helper'

describe MyRegBlocks do
  let! (:oski_blocks_proxy) { BearfactsRegblocksProxy.new({:user_id => "61889", :fake => true}) }

  context "should return some regblocks for oski" do
    before { BearfactsRegblocksProxy.stub(:new).and_return(oski_blocks_proxy) }

    subject { MyRegBlocks.new(61889).get_feed }

    its([:active_blocks]) { should_not be_empty }
    its([:inactive_blocks]) { should_not be_empty }
    its([:available]) { should be_true }
    it "active status and non-nil type on active blocks" do
      subject[:active_blocks].each do |block|
        block[:status].should == "Active"
        block[:type].should_not be_nil
      end
    end
    it "status released on inactive blocks" do
      subject[:inactive_blocks].each do |block|
        block[:status].should == "Released"
        block[:type].should_not be_nil
      end
    end
  end

  context "failing bearfacts proxy" do
    before(:each) do
      stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      BearfactsRegblocksProxy.new({:user_id => "61889", :fake => false})
    end
    after(:each) { WebMock.reset! }

    subject { MyRegBlocks.new(61889).get_feed }

    its([:available]) { should be_false }

  end
end
