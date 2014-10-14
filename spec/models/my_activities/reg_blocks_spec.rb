require 'spec_helper'

describe MyActivities::RegBlocks do
  let!(:oski_uid) { '61889' }
  let!(:oski_bearfacts_proxy) { Bearfacts::Regblocks.new({user_id: oski_uid, fake: true}) }

  let(:documented_types) { %w(alert message) }

  it { described_class.should respond_to(:append!) }
  context '2xx response from bearfacts' do
    before(:each) { Bearfacts::Regblocks.stub(:new).and_return(oski_bearfacts_proxy) }

    context 'should get properly formatted registration blocks from fake Bearfacts' do
      subject do
        activities = []
        described_class.append!(oski_uid, activities)
        activities
      end

      it { should_not be_empty }
      it 'should have valid entries' do
        subject.each do |act|
          act[:emitter].should == 'Bear Facts'
          act[:source].to_s.downcase.should_not == 'bearfacts'
          documented_types.include?(act[:type]).should be_truthy
        end
      end
    end

    context 'cleared date on very old blocks' do
      before(:each) do
        mangled_inactive = oski_bearfacts_proxy.get[:inactiveBlocks].map do |block|
          {
            clearedDate: oski_bearfacts_proxy.format_date(Time.now.to_datetime),
            blockedDate: oski_bearfacts_proxy.format_date(Time.at(0).to_datetime)
          }.reverse_merge(block)
        end
        mangled_oski_blocks = oski_bearfacts_proxy.get.merge({ inactiveBlocks: mangled_inactive })
        Bearfacts::Regblocks.any_instance.stub(:get).and_return(mangled_oski_blocks)
      end

      subject do
        activities = []
        described_class.append!(oski_uid, activities)
        activities
      end

      it { should_not be_empty }
      it 'feed should have recently cleared, very old blocks' do
        cleared_blocks = subject.select do |act|
          act[:emitter]== 'Bear Facts' && act[:type] == 'message' && act[:title].include?('Block Cleared')
        end
        cleared_blocks.length.should eq(oski_bearfacts_proxy.get[:inactiveBlocks].length)
      end

    end
  end

  context '4xx response from bearfacts proxy' do
    before(:each) { Bearfacts::Regblocks.any_instance.stub(:get).and_return({ errored: true }) }

    it 'should not malform the activities passed into append_reg_blocks' do
      my_activities = MyActivities::RegBlocks
      activities = 'foo'
      my_activities.send(:append!, oski_uid, activities)
      activities.should eq('foo')
    end
  end

  context 'nil body from proxy' do
    before { allow_any_instance_of(Bearfacts::Regblocks).to receive(:get).and_return({}) }
    it 'should not do anything' do
      activities = []
      MyActivities::RegBlocks.append!(oski_uid, activities)
      expect(activities).to eq []
    end
  end
end
