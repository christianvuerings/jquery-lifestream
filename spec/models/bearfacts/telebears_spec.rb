require "spec_helper"

describe Bearfacts::Telebears do
  let!(:fake_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => true}).get }
  let!(:live_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => false}).get }
  let!(:live_non_student){ Bearfacts::Telebears.new({user_id: '212377'}).get }

  context "fake oski recordings are valid" do
    subject { fake_oski }
    its([:xml_doc]) { should be_present }
  end

  context "should indicate a non-student" do
    subject { live_non_student }
    its([:noStudentId]) { should be_truthy }
  end

  context "live oski has a valid telebears date", testext: true do
    subject { live_oski }
    it { should_not be_blank }
  end

end

