require 'spec_helper'

describe MyActivities::Canvas do
  let!(:fake_canvas_proxy) { CanvasUserActivityStreamProxy.new(fake: true) }
  let!(:user_id) { rand(99999).to_s }
  let!(:documented_types) { %w(alert announcement assignment discussion grade_posting message webconference) }

  before(:each) do
    CanvasProxy.stub(:access_granted?).and_return(true)
    CanvasUserActivityStreamProxy.stub(:new).and_return(fake_canvas_proxy)
  end

  subject do
    activities = []
    described_class.append!(user_id, activities)
    activities
  end

  it { described_class.should respond_to(:append!) }
  it { should_not be_empty }
  it "canvas activities should be in the right format" do
    subject.each do |act|
      act[:emitter].should == 'bCourses'
      documented_types.include?(act[:type]).should be_true
    end
  end

end