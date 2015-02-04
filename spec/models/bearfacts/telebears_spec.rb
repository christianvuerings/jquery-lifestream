require "spec_helper"

describe Bearfacts::Telebears do
  let!(:fake_oski) { Bearfacts::Telebears.new({:user_id => "61889", :fake => true}) }

  it_should_behave_like 'a student data proxy' do
    let!(:proxy_class) { Bearfacts::Telebears }
    let!(:feed_key) { 'telebearsAppointment' }
  end

  it 'should support Current Term as well as Future Term' do
    default_feed = fake_oski.get
    expect(default_feed[:feed]['telebearsAppointment']['termName']).to eq 'Fall'
    current_term_feed = Bearfacts::Telebears.new(user_id: '61889', fake: true, term_id: 'CT').get
    expect(current_term_feed[:feed]['telebearsAppointment']['termName']).to eq 'Spring'
  end

end

