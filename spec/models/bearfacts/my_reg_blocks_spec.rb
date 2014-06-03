require 'spec_helper'

describe Bearfacts::MyRegBlocks do
  let! (:oski_blocks_proxy) { Bearfacts::Regblocks.new({:user_id => "61889", :fake => true}) }

  context "should return some regblocks for oski" do
    before { Bearfacts::Regblocks.stub(:new).and_return(oski_blocks_proxy) }

    subject { Bearfacts::MyRegBlocks.new(61889).get_feed }

    its([:activeBlocks]) { should_not be_empty }
    its([:inactiveBlocks]) { should_not be_empty }
    its([:unavailable]) { should be_false }
    it "active status and non-nil type on active blocks" do
      subject[:activeBlocks].each do |block|
        block[:status].should == "Active"
        block[:type].should_not be_nil
      end
    end
    it "status released on inactive blocks" do
      subject[:inactiveBlocks].each do |block|
        block[:status].should == "Released"
        block[:type].should_not be_nil
      end
    end
  end

  context "failing bearfacts proxy" do
    before(:each) do
      stub_request(:any, /#{Regexp.quote(Settings.bearfacts_proxy.base_url)}.*/).to_raise(Errno::EHOSTUNREACH)
      Bearfacts::Regblocks.new({:user_id => "61889", :fake => false})
    end

    subject { Bearfacts::MyRegBlocks.new(61889).get_feed }

    its([:unavailable]) { should be_true }

  end
end
