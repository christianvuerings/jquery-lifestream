require "spec_helper"

describe MyActivities::RegBlocks do
  let!(:oski_uid) { "61889" }
  let!(:oski_bearfacts_proxy) { BearfactsRegblocksProxy.new({:user_id => oski_uid, :fake => true}) }

  let(:documented_types) { %w(alert message) }

  it { described_class.should respond_to(:append!) }
  context "2xx response from bearfacts" do
    let(:oski_blocks) { MyRegBlocks.new(oski_uid) }

    before(:each) { BearfactsRegblocksProxy.stub(:new).and_return(oski_bearfacts_proxy) }

    context "should get properly formatted registration blocks from fake Bearfacts" do
      subject do
        activities = []
        described_class.append!(oski_uid, activities)
        activities
      end

      it { should_not be_empty }
      it "should have valid entries" do
        subject.each do |act|
          act[:emitter].should == "BearFacts"
          act[:source].should_not == "Bearfacts"
          documented_types.include?(act[:type]).should be_true
        end
      end
    end

    context "cleared date on very old blocks" do
      before(:each) do
        mangled_inactive = oski_blocks.get_feed[:inactive_blocks].map do |block|
          {
            cleared_date: oski_blocks.format_date(Time.now.to_datetime),
            blocked_date: oski_blocks.format_date(Time.at(0).to_datetime)
          }.reverse_merge(block)
        end
        mangled_oski_blocks = oski_blocks.get_feed.merge({ inactive_blocks: mangled_inactive })
        MyRegBlocks.any_instance.stub(:get_feed).and_return(mangled_oski_blocks)
      end

      subject do
        activities = []
        described_class.append!(oski_uid, activities)
        activities
      end

      it { should_not be_empty }
      it "feed should have recently cleared, very old blocks" do
        cleared_blocks = subject.select do |act|
          act[:emitter]== "BearFacts" && act[:type] == "message" && act[:title].include?("Block Cleared")
        end
        cleared_blocks.length.should eq(oski_blocks.get_feed[:inactive_blocks].length)
      end

    end
  end

  context "4xx response from bearfacts proxy" do
    before(:each) { MyRegBlocks.any_instance.stub(:get_feed).and_return({ available: false }) }

    it "should not malform the activities passed into append_reg_blocks" do
      my_activities = MyActivities::RegBlocks
      activities = "foo"
      my_activities.send(:append!, oski_uid, activities)
      activities.should eq("foo")
    end
  end
end
