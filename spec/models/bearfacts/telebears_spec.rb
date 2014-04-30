require "spec_helper"

describe Bearfacts::Telebears do
  let!(:fake_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => true}).get }
  let!(:live_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => false}).get }
  let!(:live_non_student){ Bearfacts::Telebears.new({user_id: '212377'}).get }

  context "fake oski recordings are valid" do
    subject { fake_oski }

    it { should_not be_blank }
  end

  context "should 400 with a non-student" do
    subject { live_non_student }

    its([:body]) { should eq "Lookup of student_id for uid 212377 failed, cannot call Bearfacts API" }
    its([:statusCode]) { should eq(400) }
  end

  context "live oski has a valid telebears date", testext: true do
    subject { live_oski }

    it { should_not be_blank }
  end

end

