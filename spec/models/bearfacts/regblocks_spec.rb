require 'spec_helper'

describe Bearfacts::Regblocks do

  context 'getting oskis regblocks from fake data set' do
    subject { Bearfacts::Regblocks.new({user_id: '61889', fake: true}).get }

    its([:activeBlocks]) { should_not be_empty }
    its([:inactiveBlocks]) { should_not be_empty }
    its([:errored]) { should be_false }
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

  context 'with a non-student input' do
    subject { Bearfacts::Regblocks.new({user_id: '0', fake: true}).get }
    it 'should fail gracefully on a user whose student_id cannot be found' do
      subject[:noStudentId].should be_true
    end
  end

  context 'getting data from a real server', testext: true do
    subject { Bearfacts::Regblocks.new({user_id: '61889', fake: false}).get }
    it 'should get Oskis reg blocks' do
      subject.should_not be_nil
    end
  end

end
