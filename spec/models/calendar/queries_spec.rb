require 'spec_helper'

describe Calendar::Queries do

  let(:users) {
    user = Calendar::User.new
    user.uid = 300939
    [user]
  }

  describe '#get_all_courses' do
    context 'with a non-empty whitelist' do
      subject { Calendar::Queries.get_all_courses(users) }
      it 'returns a list of courses in the configured departments' do
        expect(subject).to be
        if Calendar::Queries.test_data?
          expect(subject.length).to be >= 1
        end
      end
    end
    context 'with an empty whitelist' do
      subject { Calendar::Queries.get_all_courses([]) }
      it 'returns an empty list' do
        expect(subject).to be_empty
      end
    end
  end

  describe '#get_whitelisted_students_in_course' do
    subject { Calendar::Queries.get_whitelisted_students_in_course(users, term_yr, term_cd, ccn) }
    let(:term_yr) { 2013 }
    let(:term_cd) { 'D' }
    let(:ccn) { 7309 }
    it 'returns a list of email addresses for whitelisted users in the specified course' do
      expect(subject).to be
    end
  end
end
