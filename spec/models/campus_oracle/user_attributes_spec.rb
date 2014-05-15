require "spec_helper"

describe CampusOracle::UserAttributes do
  subject {CampusOracle::UserAttributes.new(user_id: uid).get_feed_internal}

  shared_examples_for 'a parser for roles' do |expected_roles|
    it 'only sets expected roles' do
      expected_roles.each do |role|
        expect(subject[:roles][role]).to be_true
      end
      subject[:roles].each do |role, value|
        expect(value).to be_false unless expected_roles.include?(role)
      end
    end
  end

  context 'working against test data', if: CampusOracle::Queries.test_data? do
    context 'student with blank REG_STATUS_CD' do
      let(:uid) {300847}
      it 'includes expected feed values' do
        expect(subject[:reg_status][:summary]).to eq 'Not Registered'
        expect(subject[:reg_status][:needsAction]).to be_true
        expect(subject[:education_level]).to eq 'Masters'
        expect(subject[:california_residency][:summary]).to eq 'Non-Resident'
      end
    end
    describe 'roles' do
      context 'student' do
        let(:uid) {300846}
        it_behaves_like 'a parser for roles', [:student, :registered]
      end
      context 'staff member and ex-student' do
        let(:uid) {238382}
        it_behaves_like 'a parser for roles', [:exStudent, :staff]
      end
      context 'user without affiliations data' do
        let(:uid) {321765}
        it_behaves_like 'a parser for roles', []
      end
      context 'guest' do
        let(:uid) {19999969}
        it_behaves_like 'a parser for roles', [:guest]
      end
    end
  end

end
