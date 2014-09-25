require 'spec_helper'

describe Calendar::Queries do

  describe '#get_all_courses' do
    context 'getting all courses regardless of enrollment' do
      subject { Calendar::Queries.get_all_courses }
      it 'returns a list of courses in the configured departments' do
        expect(subject).to be
        if Calendar::Queries.test_data?
          expect(subject.length).to be >= 1
        end
      end
      it 'should respect business rule about print_cd of A in class schedule data' do
        if Calendar::Queries.test_data?
          p "Subject = #{subject}"
          expect(subject.length).to eq 4
        end
      end
    end
  end

  describe '#get_whitelisted_students_in_course' do
    subject { Calendar::Queries.get_whitelisted_students_in_course(users, term_yr, term_cd, ccn) }
    let(:term_yr) { 2013 }
    let(:term_cd) { 'D' }
    let(:ccn) { 7309 }

    context 'with a user in the whitelist' do
      let(:users) {
        user = Calendar::User.create({uid: 300939})
        [user]
      }
      it 'returns a list of email addresses for whitelisted users in the specified course' do
        expect(subject).to be
        if Calendar::Queries.test_data?
          expect(subject.length).to be >= 1
        end
      end
    end

    context 'with an empty whitelist' do
      subject { Calendar::Queries.get_whitelisted_students_in_course([], term_yr, term_cd, ccn) }
      it 'returns an empty list' do
        expect(subject).to be_empty
      end
    end
  end
end
