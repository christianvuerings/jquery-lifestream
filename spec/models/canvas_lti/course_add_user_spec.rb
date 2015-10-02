describe CanvasLti::CourseAddUser do
  let(:common_first_name) { 'Bryan' }
  let(:common_last_name) { 'Cranston' }
  let(:common_email) { 'bryan.cranston' }

  let(:common_uid) { rand(99999).to_s }
  let(:current_student_uid) { "#{common_uid}1" }
  let(:current_employee_former_student_uid) { "#{common_uid}2" }
  let(:former_employee_former_student_uid) { "#{common_uid}3" }
  let(:user_with_expired_calnet_account_uid) { "#{common_uid}4" }

  let(:current_student) do
    {
      'ldap_uid'=>current_student_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@berkeley.edu",
      'student_id'=>rand(999999),
      'affiliations'=>'STUDENT-TYPE-REGISTERED',
      'person_type'=>'U'
    }
  end

  let (:current_employee_former_student) do
    {
      'ldap_uid'=>current_employee_former_student_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@media.berkeley.edu",
      'student_id'=>rand(999999),
      'affiliations'=>'EMPLOYEE-TYPE-STAFF,STUDENT-STATUS-EXPIRED',
      'person_type'=>'S'
    }
  end

  let (:former_employee_former_student) do
    {
      'ldap_uid'=>former_employee_former_student_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@example.com",
      'student_id'=>rand(999999),
      'affiliations'=>'EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED',
      'person_type'=>'G'
    }
  end

  let(:user_with_expired_calnet_account) do
    {
      'ldap_uid'=>user_with_expired_calnet_account_uid,
      'first_name'=>common_first_name,
      'last_name'=>common_last_name,
      'email_address'=>"#{common_email}@berkeley.edu",
      'student_id'=>rand(999999),
      'affiliations'=>'STUDENT-TYPE-REGISTERED',
      'person_type'=>'Z'
    }
  end

  let (:people_array) do
    [
      current_student,
      current_employee_former_student,
      former_employee_former_student,
      user_with_expired_calnet_account
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

  # This points to a fake feed for an academic department's account.
  let(:course_account_id) {128847}
  let(:canvas_course_properties) do
    {
      statusCode: 200,
      body: {
        'account_id' => course_account_id
      }
    }
  end

  let(:canvas_account_available_roles) { [] }

  before do
    allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return(canvas_user_profile)
    allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(canvas_course_sections_list_response)
    allow_any_instance_of(Canvas::Course).to receive(:course).and_return(canvas_course_properties)
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
        expect(subject.select{ |n| n[:ldapUid] == user_with_expired_calnet_account_uid }).to be_empty
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
      result = CanvasLti::CourseAddUser.new(canvas_course_id: 767330).course_sections_list
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
    let(:user_id) { random_id }
    let(:role_id) { 1773 }
    let(:canvas_course_id) { 864215 }
    subject { CanvasLti::CourseAddUser.new(user_id: user_id, canvas_course_id: canvas_course_id)}
    before do
      allow_any_instance_of(CanvasCsv::UserProvision).to receive(:import_users).with(['260506']).and_return true
      allow_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(canvas_user_id, role_id).and_return(statusCode: 200)
    end

    it 'adds user to Canvas course section using canvas user id' do
      expect_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(canvas_user_id, role_id).and_return(statusCode: 200)
      result = subject.add_user_to_course_section('260506', role_id, '864215')
      expect(result).to be_truthy
    end

    context 'when user profile not found in Canvas' do
      before do
        sis_user_profile_stub_for_caller = double()
        sis_user_profile_stub1 = double()
        sis_user_profile_stub2 = double()
        allow(sis_user_profile_stub_for_caller).to receive(:get).and_return(canvas_user_profile)
        allow(sis_user_profile_stub1).to receive(:get).and_return(nil)
        allow(sis_user_profile_stub2).to receive(:get).and_return(canvas_user_profile)
        allow(Canvas::SisUserProfile).to receive(:new).and_return(sis_user_profile_stub_for_caller, sis_user_profile_stub1, sis_user_profile_stub2)
      end
      it 'imports user via sis import and refreshes cached profile' do
        expect(Canvas::SisUserProfile).to receive(:expire).with('260506')
        expect_any_instance_of(CanvasCsv::UserProvision).to receive(:import_users).with(['260506']).and_return true
        result = subject.add_user_to_course_section('260506', role_id, '864215')
        expect(result).to eq true
      end
    end
  end

  context 'when adding user to a course' do
    let(:user_id) { random_id }
    let(:canvas_course_id) { 864215 }
    let(:teacher_role_id) { 1773 }
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
    subject { CanvasLti::CourseAddUser.new(user_id: user_id, canvas_course_id: canvas_course_id)}
    before do
      allow_any_instance_of(Canvas::SisUserProfile).to receive(:new).with(:user_id => current_student_uid).and_return(double(get: canvas_user_profile))
    end

    it 'enrolls user in Canvas course' do
      expect_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, teacher_role_id).and_return enroll_user_response
      result = subject.add_user_to_course(current_student_uid, 'Teacher')
      expect(result).to be_an_instance_of Hash
      expect(result['id']).to eq 20959
      expect(result['root_account_id']).to eq 90242
      expect(result['enrollment_state']).to eq 'active'
      expect(result['role']).to eq 'TeacherEnrollment'
      expect(result['role_id']).to eq teacher_role_id
    end

    describe '#defined_course_roles' do
      it 'returns the available account roles' do
        result = subject.defined_course_roles
        labels = result.collect {|r| r['label']}
        expect(labels).to include('TA', 'Teacher', 'Observer', 'Designer')
        expect(labels).to include('Lead TA', 'Reader', 'Waitlist Student')
      end
    end

  end

  describe '#granting_roles_map' do
    let(:user_id) { random_id }
    let(:canvas_course_id) { random_id.to_i }
    let(:admin_user_roles) { ['globalAdmin'] }
    let(:student_course_user_roles) { ['Student'] }
    let(:observer_course_user_roles) { ['Observer'] }
    let(:ta_course_user_roles) { ['TA'] }
    let(:lead_ta_course_user_roles) { ['Lead TA'] }
    let(:reader_course_user_roles) { ['Reader'] }
    let(:maintainer_course_user_roles) { ['Maintainer'] }
    let(:teacher_course_user_roles) { ['Teacher'] }
    let(:owner_course_user_roles) { ['Owner'] }
    let(:designer_course_user_roles) { ['Designer'] }
    let(:privileged_roles) { ['Student', 'Waitlist Student', 'Teacher', 'TA', 'Lead TA', 'Reader', 'Designer', 'Observer'] }
    let(:ta_roles) { ['Student', 'Waitlist Student', 'Observer'] }

    subject { CanvasLti::CourseAddUser.new(user_id: user_id, canvas_course_id: canvas_course_id) }

    it 'returns all roles when the user is indicated to be a global admin' do
      result = subject.granting_roles_map(admin_user_roles)
      expect(result.keys).to eq privileged_roles
      expect(result.compact.size).to eq result.size
    end

    it 'returns all roles when the user is a teacher' do
      result = subject.granting_roles_map(teacher_course_user_roles)
      expect(result.keys).to eq privileged_roles
    end

    it 'returns all roles when the user is a designer' do
      result = subject.granting_roles_map(designer_course_user_roles)
      expect(result.keys).to eq privileged_roles
    end

    it 'returns only student and observer roles when the user is only a teachers assistant' do
      result = subject.granting_roles_map(ta_course_user_roles)
      expect(result.keys).to eq ta_roles
    end

    it 'returns TA-granted roles when the user is a Lead TA' do
      result = subject.granting_roles_map(lead_ta_course_user_roles)
      expect(result.keys).to eq ta_roles
    end

    it 'returns no roles when the user is only a student' do
      result = subject.granting_roles_map(student_course_user_roles)
      expect(result).to eq({})
    end

    it 'returns no roles when the user is only an observer' do
      result = subject.granting_roles_map(observer_course_user_roles)
      expect(result).to eq({})
    end

    it 'returns no roles when the user is a Reader' do
      result = subject.granting_roles_map(reader_course_user_roles)
      expect(result).to eq({})
    end

    context 'when in a Project site' do
      let(:maintainer_course_user_roles) { ['Maintainer'] }
      let(:owner_course_user_roles) { ['Owner'] }
      let(:canvas_course_properties) do
        {
          statusCode: 200,
          body: {
            'account_id' => 1379095
          }
        }
      end
      it 'returns all project site roles when the user is an owner' do
        result = subject.granting_roles_map(owner_course_user_roles)
        # The "Waitlist Student" role is only defined for Official Courses.
        expect(result.keys).to include 'Student', 'Teacher', 'TA', 'Lead TA', 'Reader', 'Designer'
        expect(result.keys).to include 'Owner', 'Maintainer', 'Member'
      end
      it 'returns only student and observer level roles when the user is only a maintainer' do
        result = subject.granting_roles_map(maintainer_course_user_roles)
        expect(result.keys).to include 'Student', 'Observer'
        expect(result.keys).to include 'Member'
      end
    end

  end

  describe '#roles_to_labels' do
    let(:user_id) { random_id }
    let(:canvas_course_id) { random_id.to_i }
    subject { CanvasLti::CourseAddUser.new(user_id: user_id, canvas_course_id: canvas_course_id) }

    let(:empty_course_user) { {'enrollments' => []} }
    let(:student_enrollment) { {'role' => 'StudentEnrollment'} }
    let(:designer_enrollment) { {'role' => 'DesignerEnrollment'} }
    let(:owner_enrollment) { {'role' => 'Owner'} }
    let(:maintainer_enrollment) { {'role' => 'Maintainer'} }

    context 'if course user exists in canvas' do
      let(:course_user) { {'enrollments' => [student_enrollment, designer_enrollment]} }
      it 'returns roles list' do
        course_user_roles = subject.roles_to_labels(course_user)
        expect(course_user_roles).to eq ['Student', 'Designer']
      end
    end

    context 'if course user is owner' do
      let(:course_user) { {'enrollments' => [owner_enrollment]} }
      it 'returns roles with owner role indicated' do
        course_user_roles = subject.roles_to_labels(course_user)
        expect(course_user_roles).to eq ['Owner']
      end
    end

    context 'if course user is maintainer' do
      let(:course_user) { {'enrollments' => [maintainer_enrollment]} }
      it 'returns roles with maintainer role indicated' do
        course_user_roles = subject.roles_to_labels(course_user)
        expect(course_user_roles).to eq ['Maintainer']
      end
    end

    context 'if course user does not exist in canvas' do
      it 'returns roles hash' do
        course_user_roles = subject.roles_to_labels(nil)
        expect(course_user_roles).to eq []
      end
    end

    context 'if course user enrollments are empty' do
      it 'returns roles hash' do
        course_user_roles = subject.roles_to_labels(empty_course_user)
        expect(course_user_roles).to eq []
      end
    end
  end


end
