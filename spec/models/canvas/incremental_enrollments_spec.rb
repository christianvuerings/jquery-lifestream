require "spec_helper"

describe Canvas::IncrementalEnrollments do
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

  let(:canvas_section_enrollments) do
    [
      {'id' => 1005431, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000022, 'name' => "Jeffrey Pinkerton", 'sortable_name' => "Pinkerton, Jeffrey", 'short_name' => 'Jeffrey Pinkerton', 'sis_user_id' => "21563987", 'sis_login_id' => "754320", 'login_id' => "754320" }},
      {'id' => 1005432, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000026, 'name' => "Carlos J. Dick", 'sortable_name' => "Dick, Carlos", 'short_name' => 'Carlos Dick', 'sis_user_id' => "21563990", 'sis_login_id' => "754321", 'login_id' => "754321" }},
      {'id' => 1005433, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000027, 'name' => "Roy Becerra", 'sortable_name' => "Becerra, Roy", 'short_name' => 'Roy Becerra', 'sis_user_id' => "UID:754322", 'sis_login_id' => "754322", 'login_id' => "754322" }},
      {'id' => 1005434, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000028, 'name' => "Brad U. Kinder", 'sortable_name' => "Kinder, Brad", 'short_name' => 'Brad Kinder', 'sis_user_id' => "21563992", 'sis_login_id' => "754323", 'login_id' => "754323" }},
      {'id' => 1005435, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000029, 'name' => "Franklin Rosenberg", 'sortable_name' => "Rosenberg, Franklin", 'short_name' => 'Franklin Rosenberg', 'sis_user_id' => "21563993", 'sis_login_id' => "754324", 'login_id' => "754324" }},
      {'id' => 1005436, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000030, 'name' => "Stephen K. Whalen", 'sortable_name' => "Whalen, Stephen", 'short_name' => 'Stephen K. Whalen', 'sis_user_id' => "UID:754325", 'sis_login_id' => "754325", 'login_id' => "754325" }},
      {'id' => 1005441, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000030, 'name' => "Ross Wagoner", 'sortable_name' => "Wagoner, Ross", 'short_name' => 'Ross Wagoner', 'sis_user_id' => "UID:754313", 'sis_login_id' => "754313", 'login_id' => "754313" }},
      {'id' => 1005437, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000029, 'name' => "Piper Chapman", 'sortable_name' => "Chapman, Piper", 'short_name' => 'Piper Chapman', 'sis_user_id' => "21563995", 'sis_login_id' => "754326", 'login_id' => "754326" }},
      {'id' => 1005438, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000028, 'name' => "William Corgan", 'sortable_name' => "Corgan, William", 'short_name' => 'William Corgan', 'login_id' => "wcorgan@example.com" }},
      {'id' => 1005439, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000029, 'name' => "Marcy Wretsky", 'sortable_name' => "Wretsky, Marcy", 'short_name' => 'Marcy Wretsky'}},
      {'id' => 1005440, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000030, 'name' => "Jim Iha", 'sortable_name' => "Iha, Jim", 'short_name' => 'Jim Iha', 'login_id' => "jiha@example.com" }},
      {'id' => 1005442, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000030, 'name' => "Tasha Jefferson", 'sortable_name' => "Jefferson, Tasha", 'short_name' => 'Tasha Jefferson', 'sis_user_id' => "UID:754327", 'sis_login_id' => "754327", 'login_id' => "754327" }},
    ]
  end

  let(:canvas_student_enrollments) do
    {
      '754320' => {'id' => 1005431, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000022, 'name' => "Jeffrey Pinkerton", 'sortable_name' => "Pinkerton, Jeffrey", 'short_name' => 'Jeffrey Pinkerton', 'sis_user_id' => "21563987", 'sis_login_id' => "754320", 'login_id' => "754320" }},
      '754321' => {'id' => 1005432, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000026, 'name' => "Carlos J. Dick", 'sortable_name' => "Dick, Carlos", 'short_name' => 'Carlos Dick', 'sis_user_id' => "UID:754321", 'sis_login_id' => "754321", 'login_id' => "754321" }},
      '754323' => {'id' => 1005434, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "Waitlist Student", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000028, 'name' => "Brad U. Kinder", 'sortable_name' => "Kinder, Brad", 'short_name' => 'Brad Kinder', 'sis_user_id' => "21563992", 'sis_login_id' => "754323", 'login_id' => "754323" }},
      '754324' => {'id' => 1005435, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000029, 'name' => "Franklin Rosenberg", 'sortable_name' => "Rosenberg, Franklin", 'short_name' => 'Franklin Rosenberg', 'sis_user_id' => "21563993", 'sis_login_id' => "754324", 'login_id' => "754324" }},
      '754326' => {'id' => 1005437, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000029, 'name' => "Piper Chapman", 'sortable_name' => "Chapman, Piper", 'short_name' => 'Piper Chapman', 'sis_user_id' => "21563995", 'sis_login_id' => "754326", 'login_id' => "754326" }},
    }
  end

  let(:canvas_instructor_enrollments) do
    {
      '754322' => {'id' => 1005433, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000027, 'name' => "Roy Becerra", 'sortable_name' => "Becerra, Roy", 'short_name' => 'Roy Becerra', 'sis_user_id' => "UID:754322", 'sis_login_id' => "754322", 'login_id' => "754322" }},
      '754325' => {'id' => 1005436, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000030, 'name' => "Stephen K. Whalen", 'sortable_name' => "Whalen, Stephen", 'short_name' => 'Stephen K. Whalen', 'sis_user_id' => "UID:754325", 'sis_login_id' => "754325", 'login_id' => "754325" }},
      '754313' => {'id' => 1005441, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000030, 'name' => "Ross Wagoner", 'sortable_name' => "Wagoner, Ross", 'short_name' => 'Ross Wagoner', 'sis_user_id' => "UID:754313", 'sis_login_id' => "754313", 'login_id' => "754313" }},
      '754327' => {'id' => 1005442, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => nil, 'user' => { 'id' => 4000030, 'name' => "Tasha Jefferson", 'sortable_name' => "Jefferson, Tasha", 'short_name' => 'Tasha Jefferson', 'sis_user_id' => "UID:754327", 'sis_login_id' => "754327", 'login_id' => "754327" }},
    }
  end

  before do
    allow_any_instance_of(Canvas::SectionEnrollments).to receive(:list_enrollments).and_return(canvas_section_enrollments)
  end

  describe '.canvas_section_enrollments' do
    it "raises exception if canvas_section_id argument not an integer" do
      expect { Canvas::IncrementalEnrollments.canvas_section_enrollments(123456) }.to raise_error(ArgumentError)
    end

    it "returns section enrollments with students and instructors segregated" do
      result = Canvas::IncrementalEnrollments.canvas_section_enrollments('123456')
      expect(result).to be_an_instance_of Hash
      expect(result[:students]).to be_an_instance_of Hash
      expect(result[:instructors]).to be_an_instance_of Hash
      expect(result[:students].count).to eq 5
      expect(result[:instructors].count).to eq 4
      expect(result[:students]['754320']['id']).to eq 1005431
      expect(result[:students]['754321']['id']).to eq 1005432
      expect(result[:students]['754323']['id']).to eq 1005434
      expect(result[:students]['754324']['id']).to eq 1005435
      expect(result[:instructors]['754322']['id']).to eq 1005433
      expect(result[:instructors]['754325']['id']).to eq 1005436
      expect(result[:instructors]['754313']['id']).to eq 1005441
      expect(result[:instructors]['754327']['id']).to eq 1005442
    end

    it "returns section enrollments without non-sis users" do
      result = Canvas::IncrementalEnrollments.canvas_section_enrollments('123456')
      expect(result).to be_an_instance_of Hash
      expect(result[:students]).to be_an_instance_of Hash
      result[:students].each do |login_id, student|
        expect(student['user']['sis_user_id']).to be_an_instance_of String
        expect(student['user']['sis_user_id'].length > 0).to be_true
      end
    end

    it "logs existence of non-sis user enrollments" do
      logger = double
      allow(Canvas::IncrementalEnrollments).to receive(:logger).and_return(logger)
      expect(logger).to receive(:warn).with("Canvas User IDs - 4000028, 4000029, 4000030 - enrolled in Canvas Section ID # 123456 without SIS User ID present").and_return(nil)
      result = Canvas::IncrementalEnrollments.canvas_section_enrollments('123456')
    end
  end

  describe '#refresh_enrollments_in_section' do
    let(:canvas_section_id) { random_id }

    before do
      expect(Canvas::IncrementalEnrollments).to receive(:canvas_section_enrollments).with(canvas_section_id).
        and_return({:students => "students for #{canvas_section_id}", :instructors => "instructors for #{canvas_section_id}"})
    end

    it 'triggers updates for student and instructor enrollments for term specified' do
      subject.should_receive(:refresh_students_in_section).with('campus_section', 'CRS:LAW-227-2014-B', 'SEC:2014-B-49613',
        "students for #{canvas_section_id}", 'enrollments_csv', 'known_users', 'users_csv').ordered.and_return(nil)
      subject.should_receive(:refresh_teachers_in_section).with('campus_section', 'CRS:LAW-227-2014-B', 'SEC:2014-B-49613',
        'teacher', "instructors for #{canvas_section_id}",
        'enrollments_csv', 'known_users', 'users_csv').ordered.and_return(nil)
      subject.refresh_enrollments_in_section('campus_section', 'CRS:LAW-227-2014-B', 'SEC:2014-B-49613', 'teacher',
        canvas_section_id, 'enrollments_csv', 'known_users', 'users_csv')
    end
  end

  describe "#refresh_students_in_section" do
    let(:course_id)       { "CRS:EDUC-140AC-2014-B" }
    let(:section_id)      { "SEC:2014-B-1050123" }
    let(:campus_section)  { Canvas::Proxy.sis_section_id_to_ccn_and_term(section_id) }
    let(:campus_data_rows_enrolled_students) do
      [
        {"ldap_uid"=>"754320", "enroll_status"=>"E", "student_id"=>"21563987", "first_name"=>"Jeffrey", "last_name"=>"Pinkerton", "email_address"=>"jeffrey.pinkerton@berkeley.edu", "affiliations"=>"STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"754321", "enroll_status"=>"E", "student_id"=>"21563990", "first_name"=>"Carlos J.", "last_name"=>"Dick", "email_address"=>"carlos.dick@example.com", "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC,STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"754322", "enroll_status"=>"W", "student_id"=>"23270877", "first_name"=>"Andrew", "last_name"=>"Steinbeck", "email_address"=>"andrew.steinbeck@berkeley.edu", "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC,STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"754323", "enroll_status"=>"E", "student_id"=>"21563992", "first_name"=>"Sally", "last_name"=>"Lundstrom", "email_address"=>"lundstrom.sally@berkeley.edu", "affiliations"=>"STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"754325", "enroll_status"=>"C", "student_id"=>"21563378", "first_name"=>"Ray", "last_name"=>"Irvin", "email_address"=>"rayirvin@berkeley.edu", "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC,STUDENT-TYPE-REGISTERED"},
        {"ldap_uid"=>"999999", "enroll_status"=>"D", "student_id"=>"999999", "first_name"=>"Bad", "last_name"=>"Student", "email_address"=>"badstudent@berkeley.edu", "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC,STUDENT-TYPE-REGISTERED"}
      ]
    end

    before do
      allow(CampusOracle::Queries).to receive(:get_enrolled_students).and_return(campus_data_rows_enrolled_students)
      subject.refresh_students_in_section(campus_section, course_id, section_id, canvas_student_enrollments, enrollments_csv, known_users, users_csv)
    end

    it 'has no more CSV rows than expected' do
      expect(enrollments_csv.length).to eq(5)
    end

    it "makes no modifications to existing enrollments" do
      # UID 754320 is supposed to be left alone - Student ID: 21563987
      # UID 754321 is supposed to be updated from staff to student ID, but the enrollment is left alone
      expect(enrollments_csv.select {|entry| entry["user_id"] == "21563987"}.count).to eq 0
      expect(enrollments_csv.select {|entry| entry["user_id"] == "21563990"}.count).to eq 0
    end

    it "adds new student enrollments not detected in canvas enrollments list" do
      # UID 754322 is supposed to be new and waitlisted - Student ID: 23270877
      # UID 754325 is supposed to be new with normal student role - Student ID: 21563378
      {'23270877' => 'Waitlist Student', '21563378' => 'student'}.each do |student_id, role|
        matching = enrollments_csv.select {|entry| entry['user_id'] == student_id}
        expect(matching.count).to eq 1
        expect(matching[0]['role']).to eq role
      end
    end

    it "updates student enrollments with modified role" do
      # UID 754323 is supposed to be updated due to enrollment status change - Student ID: 21563992
      matching = enrollments_csv.select {|entry| entry['user_id'] == '21563992'}
      expect(matching.count).to eq 2
      expect(matching.select {|entry| entry['role'] == 'Waitlist Student'}[0]['status']).to eq 'deleted'
      expect(matching.select {|entry| entry['role'] == 'student'}[0]['status']).to eq 'active'
    end

    it "drops sis based student enrollments not detected in campus enrollment list" do
      # UID 754324 is no longer officially enrolled - Student ID: 21563993
      expect(enrollments_csv.select {|entry| entry["user_id"] == "21563993"}.count).to eq 1
      enrollments_csv_entry = enrollments_csv.select {|entry| entry["user_id"] == "21563993"}.first
      expect(enrollments_csv_entry['status']).to eq "deleted"
    end

    it "excludes manually created student enrollments not detected in campus enrollments list" do
      # UID 754326 is manually enrolled - Student ID: 21563995
      expect(enrollments_csv.select {|entry| entry["user_id"] == "21563995"}.count).to eq 0
    end

    it 'ignores dropped enrollments' do
      # UID 999999 has dropped the course
      expect(enrollments_csv.select {|entry| entry["user_id"] == "999999"}.count).to eq 0
    end

    it "updates all enrollments with sis student role" do
      enrollments_csv.each do |entry|
        expect(['student','Waitlist Student'].include?(entry['role'])).to be_true
      end
    end
  end

  describe "#refresh_teachers_in_section" do
    let(:course_id)       { "CRS:EDUC-140AC-2014-B" }
    let(:section_id)      { "SEC:2014-B-1050123" }
    let(:campus_section)  { Canvas::Proxy.sis_section_id_to_ccn_and_term(section_id) }
    let(:instructor_role) { 'teacher' }
    let(:campus_data_rows_enrolled_instructors) do
      [
        {"person_name"=>"Bryan Wagner", "ldap_uid"=>"754311", "instructor_func"=>"1", "first_name"=>"Bryan", "last_name"=>"Wagner", "email_address"=>"bwagner@berkeley.edu", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC"},
        {"person_name"=>"Roy Becerra", "ldap_uid"=>"754322", "instructor_func"=>"1", "first_name"=>"Roy", "last_name"=>"Becerra", "email_address"=>"roy.becerra@berkeley.edu", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC"},
        {"person_name"=>"Ross Wagoner", "ldap_uid"=>"754313", "instructor_func"=>"1", "first_name"=>"Ross", "last_name"=>"Wagner", "email_address"=>"ross.wagoner@berkeley.edu", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC,STUDENT-TYPE-REGISTERED"},
        {"person_name"=>"Do Quang Hoa", "ldap_uid"=>"754314", "instructor_func"=>"1", "first_name"=>"Do Quang", "last_name"=>"Hoa", "email_address"=>"dqhoa@berkeley.edu", "student_id"=>nil, "affiliations"=>"EMPLOYEE-TYPE-ACADEMIC"},
      ]
    end
    let(:campus_data_rows_sections) do
      [
        {'primary_secondary_cd' => campus_section_primary_flag}
      ]
    end
    before do
      allow(CampusOracle::Queries).to receive(:get_section_instructors).and_return(campus_data_rows_enrolled_instructors)
      subject.refresh_teachers_in_section(campus_section, course_id, section_id, instructor_role,
        canvas_instructor_enrollments, enrollments_csv, known_users, users_csv)
    end

    it 'has no more CSV rows than expected' do
      expect(enrollments_csv.length).to eq(3)
    end

    it "leaves makes no modifications to existing enrollments" do
      # LDAP UID 754322 - Roy Becerra, should be left alone
      # LDAP UID 754313 - Ross Waggoner, should be left alone
      expect(enrollments_csv.select {|entry| entry["user_id"] == "UID:754322"}.count).to eq 0
      expect(enrollments_csv.select {|entry| entry["user_id"] == "UID:754313"}.count).to eq 0
    end


    it "adds new instructor enrollments not detected in canvas enrollments list" do
      # LDAP UID 754311 - Bryan Wagner, should be added
      # LDAP UID 754314 - Do Quang Hoa, should be added
      expected_enrollment_1 = enrollments_csv.select {|entry| entry["user_id"] == "UID:754311"}
      expected_enrollment_2 = enrollments_csv.select {|entry| entry["user_id"] == "UID:754314"}
      expect(expected_enrollment_1[0]).to be_an_instance_of Hash
      expect(expected_enrollment_2[0]).to be_an_instance_of Hash
      expect(expected_enrollment_1[0]['role']).to eq "teacher"
      expect(expected_enrollment_2[0]['role']).to eq "teacher"
    end

    it "drops sis based instructor enrollments not detected in campus enrollment list" do
      # LDAP UID 754325 - Stephen K Whalen, is no longer officially assigned
      expect(enrollments_csv.select {|entry| entry["user_id"] == "UID:754325"}.count).to eq 1
      expected_enrollment = enrollments_csv.select {|entry| entry["user_id"] == "UID:754325"}
      expect(expected_enrollment[0]).to be_an_instance_of Hash
      expect(expected_enrollment[0]['role']).to eq "teacher"
      expect(expected_enrollment[0]['status']).to eq "deleted"
    end

    it "excludes manually created instructor enrollments not detected in campus enrollments list" do
      # LDAP UID 754327 - Tasha Jefferson, is not officially assigned but manually added
      # '754327' => {'id' => 1005439, 'course_id' => 1050123, 'root_account_id' => 90245, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment", 'enrollment_state' => "active", 'sis_import_id' => 167, 'user' => { 'id' => 4000030, 'name' => "Tasha Jefferson", 'sortable_name' => "Jefferson, Tasha", 'short_name' => 'Tasha Jefferson', 'sis_user_id' => "UID:754327", 'sis_login_id' => "754327", 'login_id' => "754327" }},
      expect(enrollments_csv.select {|entry| entry["user_id"] == "UID:754327"}.count).to eq 0
    end

    context 'when a different instructor roles is specified' do
      let(:instructor_role) { 'ta' }
      it 'adds TA enrollments and drops undetected Teacher enrollments' do
        # 3 existing teacher memberships will be dropped; 2 of them will be re-added as TA memberships.
        ['UID:754322', 'UID:754313'].each do |user_id|
          rows = enrollments_csv.select {|entry| entry['user_id'] == user_id}
          expect(rows.length).to eq(2)
          expect(rows.index {|r| r['role'] == 'teacher' && r['status'] == 'deleted'}).to_not be_nil
          expect(rows.index {|r| r['role'] == 'ta' && r['status'] == 'active'}).to_not be_nil
        end
      end
    end

  end

  describe '#handle_missing_enrollment' do
    context 'when enrollment originated from an SIS import' do
      let(:missing_enrollment) { canvas_section_enrollments.select {|e| e['sis_import_id'].present?}[0] }
      it 'adds the enrollment to the CSV for deletion' do
        sis_role = subject.api_role_to_csv_role(missing_enrollment['role'])
        sis_user_id = missing_enrollment['user']['sis_user_id']
        expect(subject).to receive(:append_enrollment_deletion).with(course_id, section_id, sis_role, sis_user_id, enrollments_csv).and_return(nil)
        subject.handle_missing_enrollment(uid, course_id, section_id, missing_enrollment, enrollments_csv)
      end
    end
    context 'when enrollment did not originate from an SIS import' do
      let(:missing_enrollment) { canvas_section_enrollments.select {|e| e['sis_import_id'].blank?}[0] }
      it 'does not add the enrollment to the CSV for deletion' do
        expect(subject).to_not receive(:append_enrollment_deletion)
        subject.handle_missing_enrollment(uid, course_id, section_id, missing_enrollment, enrollments_csv)
      end
    end
  end

  describe "#append_enrollment_deletion" do
    let(:sis_user_id) { "UID:12345" }
    let(:canvas_role) { 'student' }
    it "appends deletion to enrollments csv" do
      subject.append_enrollment_deletion("104979", "487187", canvas_role, sis_user_id, enrollments_csv)
      expect(enrollments_csv.length).to eq(1)
      expect(enrollments_csv[0]['course_id']).to eq "104979"
      expect(enrollments_csv[0]['section_id']).to eq "487187"
      expect(enrollments_csv[0]['user_id']).to eq sis_user_id
      expect(enrollments_csv[0]['role']).to eq canvas_role
      expect(enrollments_csv[0]['status']).to eq "deleted"
    end
  end

end
