require "spec_helper"

describe Bearfacts::Telebears do
  let!(:fake_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => true}) }
  let!(:live_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => false}) }
  let!(:live_non_student){ Bearfacts::Telebears.new({user_id: '212377'}) }

  context "fake oski recordings are valid" do
    subject { fake_oski.get }
    its([:xml_doc]) { should be_present }
  end

  context "should indicate a non-student" do
    subject { live_non_student.get }
    its([:noStudentId]) { should be_truthy }
  end

  context "live oski has a valid telebears date", testext: true do
    subject { live_oski.get }
    it { should_not be_blank }
  end

  it 'should support Current Term as well as Future Term' do
    default_feed = fake_oski.get
    expect(default_feed[:xml_doc].at_css('telebearsAppointment').attr('termName')).to eq 'Fall'
    current_term_feed = Bearfacts::Telebears.new(user_id: '61889', fake: true, term_id: 'CT').get
    expect(current_term_feed[:xml_doc].at_css('telebearsAppointment').attr('termName')).to eq 'Spring'
  end

end

