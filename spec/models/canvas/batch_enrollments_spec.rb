require "spec_helper"

describe Canvas::BatchEnrollments do
  let(:uid) { rand(999999).to_s }
  let(:course_id) { rand(999999).to_s }
  let(:section_id) { rand(999999).to_s }
  let(:campus_section)  { {term_yr: '2014', term_cd: 'C', ccn: '29292'} }
  let(:enrollments_csv)  { [] }
  let(:invariable_campus_row) { {
    'ldap_uid' => uid,
    'student_id' => uid,
    'affiliations' => 'STUDENT-TYPE-REGISTERED', 'first_name' => 'Jane', 'last_name' => "Doe", 'email_address' => 'jd@example.com'
  } }
  let(:invariable_enrollment_data) { {
    'course_id' => course_id,
    'user_id' => uid,
    'section_id' => section_id,
    'status' => 'active'
  } }
  let(:known_users)  { [uid] }
  let(:users_csv)  { [] }

  shared_examples 'an enrollments and users appender' do
    context 'when user has already been added' do
      let(:known_users)  { [uid] }
      it 'leaves user records alone' do
        expect(enrollments_csv.length).to eq(1)
        expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => canvas_role))
        expect(known_users.length).to eq(1)
        expect(users_csv.length).to eq(0)
      end
    end
    context 'when user is new to Canvas' do
      let(:known_users)  { [rand(999999).to_s] }
      it 'adds user data' do
        expect(enrollments_csv.length).to eq(1)
        expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => canvas_role))
        expect(known_users.length).to eq(2)
        expect(users_csv.length).to eq(1)
      end
    end
  end

  describe '#refresh_students_in_section' do
    before do
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).and_return([enrollment_row])
      subject.refresh_students_in_section(campus_section, course_id, section_id, enrollments_csv, known_users, users_csv)
    end
    context 'when student is waitlisted' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'W') }
      let(:canvas_role) { 'Waitlist Student' }
      it_behaves_like 'an enrollments and users appender'
    end
    context 'when student is dropped' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'D') }
      it 'changes nothing' do
        expect(enrollments_csv.length).to eq(0)
        expect(users_csv.length).to eq(0)
      end
    end
    context 'when student is concurrent' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'C') }
      let(:canvas_role) { 'student' }
      it_behaves_like 'an enrollments and users appender'
    end
    context 'when normally enrolled' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'E') }
      let(:canvas_role) { 'student' }
      it_behaves_like 'an enrollments and users appender'
    end
  end

  describe '#refresh_teachers_in_section' do
    let(:campus_data_row) { invariable_campus_row.merge('instructor_func' => 1) }
    before do
      allow(CampusOracle::Queries).to receive(:get_section_instructors).and_return([campus_data_row])
      subject.refresh_teachers_in_section(campus_section, course_id, section_id, canvas_role, enrollments_csv, known_users, users_csv)
    end
    context 'in a primary section' do
      let(:canvas_role) { 'teacher' }
      it_behaves_like 'an enrollments and users appender'
    end
    context 'in a secondary section' do
      let(:canvas_role) { 'ta' }
      it_behaves_like 'an enrollments and users appender'
    end
  end

end
