require 'spec_helper'

describe Bearfacts::Regblocks do

  it_should_behave_like 'a student data proxy' do
    let!(:proxy_class) { Bearfacts::Regblocks }
    let!(:feed_key) { nil }
  end

  context 'getting oskis regblocks from fake data set' do
    subject { Bearfacts::Regblocks.new({user_id: '61889', fake: true}).get }

    its([:activeBlocks]) { should_not be_empty }
    its([:inactiveBlocks]) { should_not be_empty }
    its([:errored]) { should be_falsey }
    it 'has an active status and non-nil type on active blocks' do
      subject[:activeBlocks].each do |block|
        block[:status].should == 'Active'
        block[:type].should_not be_nil
      end
    end
    it 'has status released on inactive blocks' do
      subject[:inactiveBlocks].each do |block|
        block[:status].should == 'Released'
        block[:type].should_not be_nil
      end
    end
  end

end
