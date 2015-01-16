require "spec_helper"

describe Berkeley::Terms do
  let(:options) {{fake_now: fake_now}}
  subject {Berkeley::Terms.fetch(options)}

  shared_examples 'a list of campus terms' do
    its(:campus) {should be_is_a Hash}
    it 'is in reverse chronological order' do
      previous_term = nil
      subject.campus.each do |slug, term|
        expect(term).to be_is_a Berkeley::Term
        expect(slug).to eq term.slug
        expect(term.sis_term_status).to be_present
        if previous_term
          expect(term.start).to be < previous_term.start
          expect(term.end).to be < previous_term.end
        end
        previous_term = term
      end
    end
  end

  context 'working against test data', if: CampusOracle::Queries.test_data? do
    context 'in Fall 2013' do
      let(:fake_now) {DateTime.parse('2013-10-10')}
      it_behaves_like 'a list of campus terms'
      its('current.slug') {should eq 'fall-2013'}
      its('running.slug') {should eq 'fall-2013'}
      its('next.slug') {should eq 'spring-2014'}
      its('future.slug') {should eq 'summer-2014'}
      its('grading_in_progress') {should be_nil}
    end
    context 'during final exams' do
      let(:fake_now) {DateTime.parse('2013-12-14')}
      it_behaves_like 'a list of campus terms'
      its('current.slug') {should eq 'fall-2013'}
      its('running.slug') {should eq 'fall-2013'}
      its('next.slug') {should eq 'spring-2014'}
      its('future.slug') {should eq 'summer-2014'}
      its('grading_in_progress') {should be_nil}
    end
    context 'between terms' do
      let(:fake_now) {DateTime.parse('2013-12-31')}
      it_behaves_like 'a list of campus terms'
      its('current.slug') {should eq 'spring-2014'}
      its(:running) {should be_nil}
      its('next.slug') {should eq 'summer-2014'}
      its('future.slug') {should eq 'fall-2014'}
      its('grading_in_progress.slug') {should eq 'fall-2013'}
    end
    context 'in last of available terms' do
      let(:fake_now) {DateTime.parse('2014-11-11')}
      it_behaves_like 'a list of campus terms'
      its('current.slug') {should eq 'fall-2014'}
      its('running.slug') {should eq 'fall-2014'}
      its(:next) {should be_nil}
      its(:future) {should be_nil}
      its('grading_in_progress') {should be_nil}
    end
    context 'limiting semester range' do
      let(:options) {{oldest: 'summer-2012'}}
      it_behaves_like 'a list of campus terms'
      it 'does not include older semesters' do
        expect(subject.campus.keys.last).to eq 'summer-2012'
      end
    end
  end

end
