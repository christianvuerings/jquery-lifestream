require "spec_helper"

describe CanvasMaintainEnrollments do
  let(:uid) { rand(999999).to_s }
  let(:course_id) { rand(999999).to_s }
  let(:section_id) { rand(999999).to_s }
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

  describe '#append_enrollment_and_user' do
    before { subject.append_enrollment_and_user(course_id, section_id, enrollment_row, enrollments_csv, known_users, users_csv) }
    context 'when student is waitlisted' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'W') }
      it 'notes the waitlist status' do
        expect(enrollments_csv.length).to eq(1)
        expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => 'Waitlist Student'))
      end
    end
    context 'when student is dropped' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'D') }
      it 'changes nothing' do
        expect(enrollments_csv.length).to eq(0)
      end
    end
    context 'when student is concurrent' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'C') }
      it 'is treated as normal enrollment' do
        expect(enrollments_csv.length).to eq(1)
        expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => 'student'))
      end
    end
    context 'when normally enrolled' do
      let(:enrollment_row) { invariable_campus_row.merge('enroll_status' => 'E') }
      context 'when user has already been added' do
        let(:known_users)  { [uid] }
        it 'leaves user records alone' do
          expect(enrollments_csv.length).to eq(1)
          expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => 'student'))
          expect(known_users.length).to eq(1)
          expect(users_csv.length).to eq(0)
        end
      end
      context 'when user is new to Canvas' do
        let(:known_users)  { [rand(999999).to_s] }
        it 'adds user data' do
          expect(enrollments_csv.length).to eq(1)
          expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => 'student'))
          expect(known_users.length).to eq(2)
          expect(users_csv.length).to eq(1)
        end
      end
    end
  end

  describe '#append_teaching_and_user' do
    let(:campus_data_row) { invariable_campus_row.merge('instructor_func' => 1) }
    before { subject.append_teaching_and_user(course_id, section_id, campus_data_row, enrollments_csv, known_users, users_csv) }
    context 'when user has already been added' do
      let(:known_users)  { [uid] }
      it 'leaves user records alone' do
        expect(enrollments_csv.length).to eq(1)
        expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => 'teacher'))
        expect(known_users.length).to eq(1)
        expect(users_csv.length).to eq(0)
      end
    end
    context 'when user is new to Canvas' do
      let(:known_users)  { [rand(999999).to_s] }
      it 'adds user data' do
        expect(enrollments_csv.length).to eq(1)
        expect(enrollments_csv[0]).to eq(invariable_enrollment_data.merge('role' => 'teacher'))
        expect(known_users.length).to eq(2)
        expect(users_csv.length).to eq(1)
      end
    end
  end

end
