describe CanvasLti::CourseAddUser do
  let(:common_first_name) { 'Bryan' }
  let(:common_last_name) { 'Cranston' }
  let(:common_email) { 'bryan.cranston' }

  let(:common_uid) { rand(99999).to_s }
  let(:current_student_uid) { "#{common_uid}1" }
  let(:current_employee_former_student_uid) { "#{common_uid}2" }
  let(:former_employee_former_student_uid) { "#{common_uid}3" }

  let(:current_student) do
    {
      'ldap_uid'=>current_student_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@berkeley.edu",
      'student_id'=>rand(999999),
      'affiliations'=>'STUDENT-TYPE-REGISTERED'
    }
  end

  let (:current_employee_former_student) do
    {
      'ldap_uid'=>current_employee_former_student_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@media.berkeley.edu",
      'student_id'=>rand(999999),
      'affiliations'=>'EMPLOYEE-TYPE-STAFF,STUDENT-STATUS-EXPIRED'
    }
  end

  let (:former_employee_former_student) do
    {
      'ldap_uid'=>former_employee_former_student_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@example.com",
      'student_id'=>rand(999999),
      'affiliations'=>'EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED'
    }
  end

  let (:people_array) do
    [
      current_student,
      current_employee_former_student,
      former_employee_former_student
    ]
  end

  let(:canvas_user_id) { 3332221 }
  let(:canvas_user_profile) {
    {
      'id'=>canvas_user_id,
      'name'=>'Bryanna D. Amerson',
      'short_name'=>'Bryanna Amerson',
      'sortable_name'=>'Amerson, Bryanna',
      'sis_user_id'=>current_student_uid,
      'sis_login_id'=>current_student_uid,
      'login_id'=>current_student_uid,
      'avatar_url'=>'https://secure.gravatar.com/avatar/1234567-avatar-50.png',
      'title'=>nil,
      'bio'=>nil,
      'primary_email'=>'test-12345@example.edu'
    }
  }

  let(:canvas_course_sections_list) do
    [
      {'id' => '202184', 'name' => 'Section One Name', 'course_id' => 767330, 'sis_section_id' => nil},
      {'id' => '202113', 'name' => 'Section Two Name', 'course_id' => 767330, 'sis_section_id' => 'SEC:2013-D-12345'}
    ]
  end

  let(:canvas_course_sections_list_response) do
    {
      statusCode: 200,
      body: canvas_course_sections_list
    }
  end

  before do
    allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return(canvas_user_profile)
    allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(canvas_course_sections_list_response)
  end

  context 'when searching for users' do
    it 'raises exception if search text is not a string' do
      expect { CanvasLti::CourseAddUser.search_users({:not => 'a string'}, 'name') }.to raise_error(ArgumentError, 'Search text must be of type String')
    end

    it 'raises exception if search type is not a string' do
      expect { CanvasLti::CourseAddUser.search_users('John Doe', {:not => 'a string'}) }.to raise_error(ArgumentError, 'Search type must be of type String')
    end

    it 'raises exception if search type is not supported' do
      expect { CanvasLti::CourseAddUser.search_users('John Doe', 'phone_number') }.to raise_error(ArgumentError, 'Search type argument \'phone_number\' invalid. Must be name, email, or ldap_user_id')
    end

    shared_examples 'a filtered result set' do
      it 'includes users' do
        expect(subject).to_not be_empty
      end

      it 'does not include student id' do
        subject.each do |person|
          expect(person).not_to include('student_id')
        end
      end

      it 'includes only current affiliations' do
        expect(subject.select{ |n| n[:ldapUid] == current_student_uid }).to be_present
        expect(subject.select{ |n| n[:ldapUid] == current_employee_former_student_uid }).to be_present
        expect(subject.select{ |n| n[:ldapUid] == former_employee_former_student_uid }).to be_empty
      end
    end

    context 'when searching by name' do
      before do
        allow(CampusOracle::Queries).to(
          receive(:find_people_by_name).
          with("#{common_first_name} #{common_last_name}", CanvasLti::CourseAddUser::SEARCH_LIMIT).
          and_return(people_array))
      end
      subject { CanvasLti::CourseAddUser.search_users("#{common_first_name} #{common_last_name}", 'name') }
      it_should_behave_like 'a filtered result set'
    end

    context 'when searching by email' do
      before do
        allow(CampusOracle::Queries).to(
          receive(:find_people_by_email).
          with(common_email, CanvasLti::CourseAddUser::SEARCH_LIMIT).
          and_return(people_array))
      end
      subject { CanvasLti::CourseAddUser.search_users(common_email, 'email') }
      it_should_behave_like 'a filtered result set'
    end

    context 'when searching by LDAP uid' do
      before { allow(CampusOracle::Queries).to receive(:find_people_by_uid).with(common_uid).and_return(people_array) }
      subject { CanvasLti::CourseAddUser.search_users(common_uid, 'ldap_user_id') }
      it_should_behave_like 'a filtered result set'
    end

  end

  context 'when obtaining course sections list' do
    it 'returns list of section ids and names' do
      result = CanvasLti::CourseAddUser.course_sections_list(767330)
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 2
      expect(result[0]['id']).to eq '202184'
      expect(result[0]['name']).to eq 'Section One Name'
      expect(result[0]['course_id']).to be_nil
      expect(result[0]['sis_section_id']).to be_nil
      expect(result[1]['id']).to eq '202113'
      expect(result[1]['name']).to eq 'Section Two Name'
      expect(result[1]['course_id']).to be_nil
      expect(result[1]['sis_section_id']).to be_nil
    end
  end

  context 'when adding user to a course section' do
    before do
      allow_any_instance_of(CanvasCsv::UserProvision).to receive(:import_users).with(['260506']).and_return true
      allow_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(canvas_user_id, 'StudentEnrollment', 'active', false).and_return(statusCode: 200)
    end

    it 'raises exception when ldap_user_id is not a string' do
      expect { CanvasLti::CourseAddUser.add_user_to_course_section(260506, 'StudentEnrollment', '864215') }.to raise_error(ArgumentError, 'ldap_user_id must be a String')
    end

    it 'raises exception when role is not a string' do
      expect { CanvasLti::CourseAddUser.add_user_to_course_section('260506', 1, '864215') }.to raise_error(ArgumentError, 'role must be a String')
    end

    it 'adds user to Canvas course section using canvas user id' do
      expect_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(canvas_user_id, 'StudentEnrollment', 'active', false).and_return(statusCode: 200)
      result = CanvasLti::CourseAddUser.add_user_to_course_section('260506', 'StudentEnrollment', '864215')
      expect(result).to be_truthy
    end

    context 'when user profile not found in Canvas' do
      before do
        sis_user_profile_stub1 = double()
        sis_user_profile_stub2 = double()
        allow(sis_user_profile_stub1).to receive(:get).and_return(nil)
        allow(sis_user_profile_stub2).to receive(:get).and_return(canvas_user_profile)
        allow(Canvas::SisUserProfile).to receive(:new).and_return(sis_user_profile_stub1, sis_user_profile_stub2)
      end
      it 'imports user via sis import and refreshes cached profile' do
        expect(Canvas::SisUserProfile).to receive(:expire).with('260506')
        expect_any_instance_of(CanvasCsv::UserProvision).to receive(:import_users).with(['260506']).and_return true
        result = CanvasLti::CourseAddUser.add_user_to_course_section('260506', 'StudentEnrollment', '864215')
        expect(result).to eq true
      end
    end
  end

  context 'when adding user to a course' do
    let(:enrollment_type) { 'TeacherEnrollment' }
    let(:canvas_course_id) { '864215' }
    let(:enrollment_state) { 'active' }
    let(:owner_role_id) { Settings.canvas_proxy.projects_owner_role_id }
    let(:teacher_role_id) { 5 }
    let(:enroll_user_response) do
      {
        statusCode: 200,
        body: {
          'id' => 20959,
          'root_account_id' => 90242,
          'user_id' => 1234567,
          'course_id' => canvas_course_id,
          'course_section_id' => 1311,
          'enrollment_state' => 'active',
          'role' => 'TeacherEnrollment',
          'role_id' => teacher_role_id,
          'sis_import_id' => nil,
          'sis_course_id' => 'PROJ:18575b1ac394619a'
        }
      }
    end
    let(:enroll_user_with_role_id_response) do
      {
        statusCode: 200,
        body: enroll_user_response[:body].merge({'role' => 'Owner', 'role_id' => owner_role_id})
      }
    end
    before do
      allow_any_instance_of(Canvas::SisUserProfile).to receive(:new).with(:user_id => current_student_uid).and_return(double(get: canvas_user_profile))
      allow_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, enrollment_type, enrollment_state, false, {}).and_return enroll_user_response
    end

    it 'enrolls user in Canvas course' do
      expect_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, enrollment_type, enrollment_state, false, {}).and_return enroll_user_response
      result = CanvasLti::CourseAddUser.add_user_to_course(current_student_uid, enrollment_type, canvas_course_id)
      expect(result).to be_an_instance_of Hash
      expect(result['id']).to eq 20959
      expect(result['root_account_id']).to eq 90242
      expect(result['enrollment_state']).to eq 'active'
      expect(result['role']).to eq 'TeacherEnrollment'
      expect(result['role_id']).to eq teacher_role_id
    end

    it 'adds user to Canvas with custom role id option' do
      expect_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, enrollment_type, enrollment_state, false, {:role_id => owner_role_id}).and_return(enroll_user_with_role_id_response)
      result = CanvasLti::CourseAddUser.add_user_to_course(current_student_uid, enrollment_type, canvas_course_id, :role_id => owner_role_id)
      expect(result['root_account_id']).to eq 90242
      expect(result['enrollment_state']).to eq 'active'
      expect(result['role']).to eq 'Owner'
      expect(result['role_id']).to eq owner_role_id
    end
  end

  context 'when serving the roles a user may select when adding a new user' do
    let(:no_course_user_roles) { {'teacher'=>false, 'student'=>false, 'observer'=>false, 'designer'=>false, 'ta'=>false} }
    let(:student_course_user_roles) { no_course_user_roles.merge({'student' => true}) }
    let(:observer_course_user_roles) { no_course_user_roles.merge({'observer' => true}) }
    let(:ta_course_user_roles) { no_course_user_roles.merge({'ta' => true}) }
    let(:maintainer_course_user_roles) { no_course_user_roles.merge({'maintainer' => true}) }
    let(:teacher_course_user_roles) { no_course_user_roles.merge({'teacher' => true}) }
    let(:owner_course_user_roles) { no_course_user_roles.merge({'owner' => true}) }
    let(:designer_course_user_roles) { no_course_user_roles.merge({'designer' => true}) }
    let(:privileged_roles) { [
      {'id' => 'StudentEnrollment', 'name' => 'Student'},
      {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
      {'id' => 'DesignerEnrollment', 'name' => 'Designer'},
      {'id' => 'TaEnrollment', 'name' => 'TA'},
      {'id' => 'TeacherEnrollment', 'name' => 'Teacher'},
    ] }
    let(:ta_roles) { [
      {'id' => 'StudentEnrollment', 'name' => 'Student'},
      {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
    ] }

    it 'returns all roles when the user is indicated to be a global admin' do
      result = CanvasLti::CourseAddUser.granting_roles(no_course_user_roles, true)
      expect(result).to eq privileged_roles
    end

    it 'returns all roles when the user is a teacher' do
      result = CanvasLti::CourseAddUser.granting_roles(teacher_course_user_roles)
      expect(result).to eq privileged_roles
    end

    it 'returns all roles when the user is an owner' do
      result = CanvasLti::CourseAddUser.granting_roles(owner_course_user_roles)
      expect(result).to eq privileged_roles
    end

    it 'returns all roles when the user is a designer' do
      result = CanvasLti::CourseAddUser.granting_roles(designer_course_user_roles)
      expect(result).to eq privileged_roles
    end

    it 'returns only student and observer roles when the user is only a teachers assistant' do
      result = CanvasLti::CourseAddUser.granting_roles(ta_course_user_roles)
      expect(result).to eq ta_roles
    end

    it 'returns only student and observer roles when the user is only a maintainer' do
      result = CanvasLti::CourseAddUser.granting_roles(maintainer_course_user_roles)
      expect(result).to eq ta_roles
    end

    it 'returns no roles when the user is only a student' do
      result = CanvasLti::CourseAddUser.granting_roles(student_course_user_roles)
      expect(result).to eq []
    end

    it 'returns no roles when the user is only an observer' do
      result = CanvasLti::CourseAddUser.granting_roles(observer_course_user_roles)
      expect(result).to eq []
    end
  end

end
