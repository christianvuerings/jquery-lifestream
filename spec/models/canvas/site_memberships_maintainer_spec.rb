require "spec_helper"

describe Canvas::SiteMembershipsMaintainer do
  let(:users_maintainer) {double}
  let(:course_id) { random_ccn }
  let(:enrollments_csv)  { [] }
  let(:users_csv)  { [] }
  let(:known_users) { [] }
  let(:uid) { random_id }
  let(:sis_section_id) {"SEC:2014-B-#{course_id}"}
  let(:sis_section_ids) { [sis_section_id, "2014-D-04124", 'bababooey'] }
  let(:sis_user_id_changes) { Hash.new }
  subject {
    Canvas::SiteMembershipsMaintainer.process(course_id, sis_section_ids, enrollments_csv, users_csv, known_users, batch_mode, cached_enrollments_provider, sis_user_id_changes)
    enrollments_csv
  }

  def enrollments_for(user_id)
    subject.select {|e| e['user_id'] == "UID:#{user_id}"}
  end

  def it_adds_the_new_membership
    expect(enrollments_for(uid)).to eq [{
      'course_id' => course_id,
      'user_id' => "UID:#{uid}",
      'role' => csv_role,
      'section_id' => sis_section_id,
      'status' => 'active'
    }]
  end

  context 'batch mode' do
    let(:batch_mode) {true}
    let(:cached_enrollments_provider) {nil}
    before do
      expect_any_instance_of(Canvas::SectionEnrollments).to receive(:list_enrollments).never
    end

    # TODO This code is copied from an older test. Refactor to reduce redundancy.
    describe 'student enrollment handling' do
      shared_examples 'an enrollments and users appender' do
        it 'adds the expected CSV row' do
          expect(subject.length).to eq(1)
          expect(subject[0]).to eq(invariable_enrollment_data.merge('role' => canvas_role))
          expect(known_users).to eq [uid]
          expect(users_csv.length).to eq 1
        end
      end
      let(:invariable_campus_row) { {
        'ldap_uid' => uid,
        'student_id' => uid,
        'affiliations' => 'STUDENT-TYPE-REGISTERED'
      } }

      let(:invariable_enrollment_data) { {
        'course_id' => course_id,
        'user_id' => uid,
        'section_id' => sis_section_id,
        'status' => 'active'
      } }
      let(:campus_data_row) { invariable_campus_row.merge('enroll_status' => enroll_status) }
      before do
        allow(CampusOracle::Queries).to receive(:get_enrolled_students).and_return([campus_data_row])
        allow(CampusOracle::Queries).to receive(:get_section_instructors).and_return([])
        end
      context 'when student is waitlisted' do
        let(:enroll_status) { 'W' }
        let(:canvas_role) { 'Waitlist Student' }
        it_behaves_like 'an enrollments and users appender'
      end
      context 'when student is dropped' do
        let(:enroll_status) { 'D' }
        it 'changes nothing' do
          expect(enrollments_csv.length).to eq 0
          expect(known_users).to be_empty
          expect(users_csv.length).to eq 0
        end
      end
      context 'when student is concurrent' do
        let(:enroll_status) { 'C' }
        let(:canvas_role) { 'student' }
        it_behaves_like 'an enrollments and users appender'
      end
      context 'when normally enrolled' do
        let(:enroll_status) { 'E' }
        let(:canvas_role) { 'student' }
        it_behaves_like 'an enrollments and users appender'
        context 'when user is already known' do
          let(:known_users) { [uid] }
          it 'does not re-import the user' do
            expect(subject.length).to eq(1)
            expect(users_csv.length).to eq 0
          end
        end
      end
    end

    describe 'teacher roles based on section types' do
      # CCNs in sis_section_ids may or may not be zero-padded, but the browser always shows CCNs of length 5.
      let(:ccn_to_uid) { {rand(9999).to_s => random_id, rand(9999).to_s => random_id} }
      let(:padded_ccns) { ccn_to_uid.keys.collect {|ccn| sprintf('%05d', ccn)} }
      let(:sis_section_ids) { ["SEC:2014-B-0#{ccn_to_uid.keys[0]}", "SEC:2014-B-#{ccn_to_uid.keys[1]}"] }
      before do
        allow(CampusOracle::Queries).to receive(:get_enrolled_students).and_return([])
        allow(CampusOracle::Queries).to receive(:get_section_instructors) do |term_yr, term_cd, ccn|
          if term_yr == '2014' && term_cd == 'B'
            [{'ldap_uid' => ccn_to_uid[ccn.to_i.to_s]}]
          end
        end
        # Low-level Oracle query methods do not yet pad CCNs: CLC-4992
        allow(CampusOracle::Queries).to receive(:get_sections_from_ccns).with('2014', 'B', padded_ccns).and_return([
          {'course_cntl_num' => padded_ccns[0].to_i.to_s, 'primary_secondary_cd' => first_section_type},
          {'course_cntl_num' => padded_ccns[1].to_i.to_s, 'primary_secondary_cd' => 'S'}
        ])
      end
      context 'when a mix of primary and secondary sections' do
        let(:first_section_type) {'P'}
        it 'assigns TA role for secondary sections' do
          expect(subject.length).to eq(2)
          expect(enrollments_for(ccn_to_uid.values[0]).first['role']).to eq 'teacher'
          expect(enrollments_for(ccn_to_uid.values[1]).first['role']).to eq 'ta'
          expect(known_users.length).to eq 2
          expect(users_csv.length).to eq 2
        end
      end
      context 'when all secondary sections' do
        let(:first_section_type) {'S'}
        it 'assigns teacher role for secondary sections' do
          expect(subject.length).to eq(2)
          expect(enrollments_for(ccn_to_uid.values[0]).first['role']).to eq 'teacher'
          expect(enrollments_for(ccn_to_uid.values[1]).first['role']).to eq 'teacher'
          expect(known_users.length).to eq 2
          expect(users_csv.length).to eq 2
        end
      end
    end

  end

  context 'incremental mode' do
    let(:batch_mode) {false}
    let(:cached_enrollments_provider) {nil}
    let(:campus_data_row) { {
      'ldap_uid' => uid,
      'enroll_status' => 'E'
    } }
    let(:csv_role) {'student'}
    let(:canvas_section_enrollments) do
      [{
        'type' => existing_api_role,
        'role' => existing_api_role,
        'enrollment_state' => existing_state,
        'sis_import_id' => existing_import_id,
        'user' => {
          'login_id' => existing_uid,
          'sis_user_id' => "UID:#{existing_uid}"
        }
      }]
    end

    before do
      expect(CampusOracle::Queries).to receive(:get_enrolled_students).
        with(course_id, '2014', 'B').and_return([campus_data_row])
      allow(CampusOracle::Queries).to receive(:get_section_instructors).and_return([])
    end

    context 'live enrollments comparison' do

      before do
        expect(Canvas::SectionEnrollments).to receive(:new).with(section_id: "sis_section_id:#{sis_section_id}").and_return(double(
          list_enrollments: canvas_section_enrollments
        ))
      end

      context 'new site member' do
        let(:existing_uid) { random_id }
        let(:existing_api_role) {'Waitlist Student'}
        let(:existing_state) {'active'}
        context 'existing membership was manually added' do
          let(:existing_import_id) { nil }
          it 'leaves existing membership alone' do
            it_adds_the_new_membership
            expect(enrollments_for(existing_uid)).to be_empty
          end
        end
        context 'existing membership was added by previous import' do
          let(:existing_import_id) { rand(9999) }
          it 'removes the existing membership' do
            it_adds_the_new_membership
            expect(enrollments_for(existing_uid).size).to eq 1
            expect(enrollments_for(existing_uid).first['role']).to eq 'Waitlist Student'
            expect(enrollments_for(existing_uid).first['status']).to eq 'deleted'
          end
        end
      end
      context 'known site member' do
        let(:existing_uid) { uid }
        let(:existing_api_role) {'Waitlist Student'}
        let(:existing_state) {'active'}
        context 'existing membership was manually added' do
          let(:existing_import_id) { nil }
          it 'ignores the existing membership record' do
            it_adds_the_new_membership
          end
        end
        context 'existing membership was added by previous import' do
          let(:existing_import_id) { rand(9999) }
          context 'previous membership was deleted' do
            let(:existing_state) { 'deleted' }
            it 'ignores the existing membership record' do
              it_adds_the_new_membership
            end
          end
          context 'no change to role' do
            let(:existing_api_role) {'StudentEnrollment'}
            it 'does nothing' do
              expect(subject).to be_empty
            end
          end
          context 'changed role' do
            it 'adds the new role and deletes the old one' do
              expect(subject.size).to eq 2
              expect(subject.index {|e| e['user_id'] == "UID:#{uid}" && e['role'] == csv_role && e['status'] == 'active'}).to_not be_nil
              expect(subject.index {|e| e['user_id'] == "UID:#{uid}" && e['role'] == 'Waitlist Student' && e['status'] == 'deleted'}).to_not be_nil
            end
          end
        end
      end
    end

    context 'when cached enrollments provider present' do
      let(:cached_enrollments_provider) { Canvas::TermEnrollmentsCsv.new }
      let(:cached_enrollments_hash) do
        [
          {"course_section_id"=>"1413864","sis_section_id"=>"SEC:2014-C-24111", "user_id"=>"4906376", "role"=>"StudentEnrollment", "enrollment_state" => "active", "sis_import_id"=>"101", "user"=>{"sis_user_id" => "UID:7977", "sis_login_id"=>"7977", "login_id"=>"7977"}},
          {"course_section_id"=>"1413864","sis_section_id"=>"SEC:2014-C-24111", "user_id"=>"4906377", "role"=>"StudentEnrollment", "enrollment_state" => "active", "sis_import_id"=>"101", "user"=>{"sis_user_id" => "UID:7978", "sis_login_id"=>"7978", "login_id"=>"7978"}},
        ]
      end
      before do
        expect_any_instance_of(Canvas::SectionEnrollments).to receive(:list_enrollments).never
        expect_any_instance_of(Canvas::TermEnrollmentsCsv).to receive(:cached_canvas_section_enrollments).with(sis_section_id).and_return(cached_enrollments_hash)
      end
      it 'calls for enrollments from cached enrollment set' do
        expect(subject.count).to eq 3
        expect(subject[0]['user_id']).to eq "UID:#{uid}"
        expect(subject[1]['user_id']).to eq "UID:7977"
        expect(subject[2]['user_id']).to eq "UID:7978"
      end

      context "when new sis user id present for dropped enrollment" do
        let(:sis_user_id_changes) { { "sis_login_id:7978" => "2018903" } }
        it 'uses new sis user id' do
          expect(subject.count).to eq 3
          expect(subject[0]['user_id']).to eq "UID:#{uid}"
          expect(subject[1]['user_id']).to eq "UID:7977"
          expect(subject[2]['user_id']).to eq "2018903"
        end
      end
    end

  end

end
