require "spec_helper"

describe CanvasCourseAddUserController do

  let(:student_enrollment_hash) do
    {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241907, 'type' => "StudentEnrollment", 'role' => "StudentEnrollment"}
  end

  let(:ta_enrollment_hash) do
    {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241907, 'type' => "TaEnrollment", 'role' => "TaEnrollment"}
  end

  let(:teacher_enrollment_hash) do
    {'course_id' => 767330, 'course_section_id' => 1312468, 'id' => 20241908, 'type' => "TeacherEnrollment", 'role' => "TeacherEnrollment"}
  end

  let(:canvas_course_user_hash) do
    { 'id' => 4321321, 'name' => "Michael Steven OWEN", 'sis_user_id' => 'UID:105431', 'sis_login_id' => '105431', 'login_id' => '105431', 'enrollments' => [student_enrollment_hash] }
  end

  let(:users_found) do
    [
      { 'firstName' => 'Felix', 'lastName' => 'Gracia', 'emailAddress' => 'fgracia@example.edu', 'ldapUid' => '12890', 'affiliations' => 'EMPLOYEE-TYPE-STAFF,STUDENT-STATUS-EXPIRED' },
      { 'firstName' => 'Brian', 'lastName' => 'Spires', 'emailAddress' => 'brianlspires@example.edu', 'ldapUid' => '10054', 'affiliations' => 'EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED' },
      { 'firstName' => 'Maria', 'lastName' => 'Patterson', 'emailAddress' => 'mjpatterson@example.edu', 'ldapUid' => '4883', 'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-ACADEMIC' },
    ]
  end

  let(:course_sections_list) do
    [
      {"id" => "202184", "name" => "Section One Name"},
      {"id" => "1237009", "name" => "Section Two Name"}
    ]
  end

  let(:canvas_root_url) { 'https://ucb.beta.example.com' }
  let(:canvas_course_id) {'767330'}

  before do
    session['user_id'] = '12345'
    session['canvas_user_id'] = '43232321'
    allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_user_hash)
    allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(true)
    allow(Canvas::CourseAddUser).to receive(:course_sections_list).and_return(course_sections_list)
    allow(Settings.canvas_proxy).to receive(:url_root).and_return(canvas_root_url)
  end

  shared_examples 'a course-access protected controller' do

    context 'when serving course user role information' do

      it_should_behave_like 'an api endpoint' do
        before { allow(subject).to receive(:course_user_roles).and_raise(RuntimeError, "Something went wrong") }
        let(:make_request) { get :course_user_roles, request_params }
      end

      it_should_behave_like 'a user authenticated api endpoint' do
        let(:make_request) { get :course_user_roles, request_params }
      end

      context 'when session with canvas course user present' do

        context 'when user is student' do
          let(:canvas_course_student_hash) { canvas_course_user_hash.merge({'enrollments' => [student_enrollment_hash]}) }
          before do
            allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(false)
            allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_student_hash)
          end

          it 'returns canvas root url and course id' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['canvasRootUrl']).to eq 'https://ucb.beta.example.com'
            expect(response_json['courseId']).to eq 767330
          end

          it 'returns course user details' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['roles']).to be_an_instance_of Hash
            roles = response_json['roles']
            expect(roles).to be_an_instance_of Hash
            expect(roles['globalAdmin']).to be_falsey
            expect(roles['teacher']).to be_falsey
            expect(roles['student']).to be_truthy
            expect(roles['observer']).to be_falsey
            expect(roles['designer']).to be_falsey
            expect(roles['ta']).to be_falsey

            role_types = response_json['roleTypes']
            expect(role_types).to be_an_instance_of Array
            expect(role_types.count).to eq 1
            expect(role_types[0]).to eq 'StudentEnrollment'
          end

          it 'returns no granting roles' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['grantingRoles']).to eq []
          end
        end

        context 'when user is teachers assistant' do
          let(:canvas_course_ta_hash) { canvas_course_user_hash.merge({'enrollments' => [ta_enrollment_hash]}) }
          before do
            allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(false)
            allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_ta_hash)
          end

          it 'returns canvas root url and course id' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['canvasRootUrl']).to eq 'https://ucb.beta.example.com'
            expect(response_json['courseId']).to eq 767330
          end

          it 'returns course user details' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['roles']).to be_an_instance_of Hash
            roles = response_json['roles']
            expect(roles).to be_an_instance_of Hash
            expect(roles['globalAdmin']).to be_falsey
            expect(roles['teacher']).to be_falsey
            expect(roles['student']).to be_falsey
            expect(roles['observer']).to be_falsey
            expect(roles['designer']).to be_falsey
            expect(roles['ta']).to be_truthy

            role_types = response_json['roleTypes']
            expect(role_types).to be_an_instance_of Array
            expect(role_types.count).to eq 1
            expect(role_types[0]).to eq 'TaEnrollment'
          end

          it 'returns student and observer granting roles' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['grantingRoles']).to be_an_instance_of Array
            expect(response_json['grantingRoles']).to_not include({'id' => "TeacherEnrollment", "name" => "Teacher"})
            expect(response_json['grantingRoles']).to_not include({'id' => "TaEnrollment", "name" => "TA"})
            expect(response_json['grantingRoles']).to_not include({'id' => "DesignerEnrollment", "name" => "Designer"})
            expect(response_json['grantingRoles']).to include({'id' => "StudentEnrollment", "name" => "Student"})
            expect(response_json['grantingRoles']).to include({'id' => "ObserverEnrollment", "name" => "Observer"})
          end
        end

        context 'when user is canvas course teacher' do
          let(:canvas_course_teacher_hash) { canvas_course_user_hash.merge({'enrollments' => [teacher_enrollment_hash]}) }
          before do
            allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(false)
            allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_teacher_hash)
          end

          it 'returns canvas root url and course id' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['canvasRootUrl']).to eq 'https://ucb.beta.example.com'
            expect(response_json['courseId']).to eq 767330
          end

          it 'returns course user details' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['roles']).to be_an_instance_of Hash
            roles = response_json['roles']
            expect(roles).to be_an_instance_of Hash
            expect(roles['globalAdmin']).to be_falsey
            expect(roles['teacher']).to be_truthy
            expect(roles['student']).to be_falsey
            expect(roles['observer']).to be_falsey
            expect(roles['designer']).to be_falsey
            expect(roles['ta']).to be_falsey

            role_types = response_json['roleTypes']
            expect(role_types).to be_an_instance_of Array
            expect(role_types.count).to eq 1
            expect(role_types[0]).to eq 'TeacherEnrollment'
          end

          it 'returns all granting roles' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['grantingRoles']).to be_an_instance_of Array
            expect(response_json['grantingRoles']).to include({'id' => "TeacherEnrollment", "name" => "Teacher"})
            expect(response_json['grantingRoles']).to include({'id' => "TaEnrollment", "name" => "TA"})
            expect(response_json['grantingRoles']).to include({'id' => "DesignerEnrollment", "name" => "Designer"})
            expect(response_json['grantingRoles']).to include({'id' => "StudentEnrollment", "name" => "Student"})
            expect(response_json['grantingRoles']).to include({'id' => "ObserverEnrollment", "name" => "Observer"})
          end
        end

        context 'when user is canvas account admin' do
          before do
            allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(true)
            allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(nil)
          end

          it 'returns canvas root url and course id' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['canvasRootUrl']).to eq 'https://ucb.beta.example.com'
            expect(response_json['courseId']).to eq 767330
          end

          it 'returns canvas admin user details' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['roles']).to be_an_instance_of Hash

            roles = response_json['roles']
            expect(roles).to be_an_instance_of Hash
            expect(roles['globalAdmin']).to be_truthy
            expect(roles['teacher']).to be_falsey
            expect(roles['student']).to be_falsey
            expect(roles['observer']).to be_falsey
            expect(roles['designer']).to be_falsey
            expect(roles['ta']).to be_falsey

            role_types = response_json['roleTypes']
            expect(role_types).to eq []
          end

          it 'returns all granting roles' do
            get :course_user_roles, request_params
            expect(response.status).to eq(200)
            response_json = JSON.parse(response.body)
            expect(response_json['grantingRoles']).to be_an_instance_of Array
            expect(response_json['grantingRoles']).to include({'id' => "TeacherEnrollment", "name" => "Teacher"})
            expect(response_json['grantingRoles']).to include({'id' => "TaEnrollment", "name" => "TA"})
            expect(response_json['grantingRoles']).to include({'id' => "DesignerEnrollment", "name" => "Designer"})
            expect(response_json['grantingRoles']).to include({'id' => "StudentEnrollment", "name" => "Student"})
            expect(response_json['grantingRoles']).to include({'id' => "ObserverEnrollment", "name" => "Observer"})
          end

        end

      end

    end

    context 'when performing user search' do
      before do
        allow(Canvas::CourseAddUser).to receive(:search_users).and_return(users_found)
      end

      it_should_behave_like 'an api endpoint' do
        before { allow(subject).to receive(:search_users).and_raise(RuntimeError, "Something went wrong") }
        let(:make_request) { get :search_users, request_params.merge(searchText: "John Doe", searchType: "name") }
      end

      it_should_behave_like 'a user authenticated api endpoint' do
        let(:make_request) { get :search_users, request_params.merge(searchText: "John Doe", searchType: "name") }
      end

      it_should_behave_like 'a canvas course admin authorized api endpoint' do
        let(:make_request) { get :search_users, request_params.merge(searchText: "John Doe", searchType: "name") }
      end

      it 'returns error if searchText parameter is blank' do
        get :search_users, request_params.merge(searchText: "", searchType: "name")
        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq "Parameter 'searchText' is blank"
      end

      it 'returns error if searchType parameter is not valid' do
        get :search_users, request_params.merge(searchText: "John Doe", searchType: "weight")
        expect(response.status).to eq(400)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq "Parameter 'searchType' is invalid"
      end

      it 'returns user search results' do
        expect(Canvas::CourseAddUser).to receive(:search_users).with('John Doe', 'name').and_return(users_found)
        get :search_users, request_params.merge(searchText: "John Doe", searchType: "name")
        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response['users']).to be_an_instance_of Array
        expect(json_response['users'].count).to eq 3
        json_response['users'].each do |user|
          expect(user).to be_an_instance_of Hash
        end
      end
    end

    context "when obtaining list of course sections" do

      it_should_behave_like "an api endpoint" do
        before { subject.stub(:course_sections).and_raise(RuntimeError, "Something went wrong") }
        let(:make_request) { get :course_sections, request_params }
      end

      it_should_behave_like "a user authenticated api endpoint" do
        let(:make_request) { get :course_sections, request_params }
      end

      it_should_behave_like "a canvas course admin authorized api endpoint" do
        let(:make_request) { get :course_sections, request_params }
      end

      it "returns sections for search" do
        get :course_sections, request_params
        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response['courseSections']).to be_an_instance_of Array
        expect(json_response['courseSections'].count).to eq 2
        expect(json_response['courseSections'][0]).to be_an_instance_of Hash
        expect(json_response['courseSections'][0]['id']).to eq "202184"
        expect(json_response['courseSections'][0]['name']).to eq "Section One Name"
        expect(json_response['courseSections'][1]).to be_an_instance_of Hash
        expect(json_response['courseSections'][1]['id']).to eq "1237009"
        expect(json_response['courseSections'][1]['name']).to eq "Section Two Name"
      end
    end

    context "when adding user to course" do
      before { allow(Canvas::CourseAddUser).to receive(:add_user_to_course_section).and_return(true) }

      it_should_behave_like "an api endpoint" do
        before { subject.stub(:add_user).and_raise(RuntimeError, "Something went wrong") }
        let(:make_request) { post :add_user, request_params.merge(ldapUserId: "260506", roleId: "StudentEnrollment", sectionId: 864215) }
      end

      it_should_behave_like "a user authenticated api endpoint" do
        let(:make_request) { post :add_user, request_params.merge(ldapUserId: "260506", roleId: "StudentEnrollment", sectionId: 864215) }
      end

      it_should_behave_like "a canvas course admin authorized api endpoint" do
        let(:make_request) { post :add_user, request_params.merge(ldapUserId: "260506", roleId: "StudentEnrollment", sectionId: 864215) }
      end

      context "when role specified is authorized" do
        let(:ta_roles) { [
          {'id' => 'StudentEnrollment', 'name' => 'Student'},
          {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
        ] }
        before { allow(Canvas::CourseAddUser).to receive(:granting_roles).and_return(ta_roles) }

        it "adds user to course section" do
          post :add_user, request_params.merge(ldapUserId: "260506", roleId: "StudentEnrollment", sectionId: "864215")
          expect(response.status).to eq(200)
          json_response = JSON.parse(response.body)
          expect(json_response['userAdded']).to be_an_instance_of Hash
          expect(json_response['userAdded']['ldapUserId']).to eq "260506"
          expect(json_response['userAdded']['roleId']).to eq "StudentEnrollment"
          expect(json_response['userAdded']['sectionId']).to eq "864215"
        end
      end

      context "when role specified is not authorized" do
        let(:ta_roles) { [
          {'id' => 'StudentEnrollment', 'name' => 'Student'},
          {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
        ] }
        before { allow(Canvas::CourseAddUser).to receive(:granting_roles).and_return(ta_roles) }

        it "denies unauthorized roles" do
          post :add_user, request_params.merge(ldapUserId: "260506", roleId: "TaEnrollment", sectionId: "864215")
          expect(response.status).to eq 403
          expect(response.body).to eq " "
        end
      end

    end

  end

  context 'standalone in CalCentral with explicit Canvas course ID' do
    let(:request_params) { {canvas_course_id: canvas_course_id} }
    it_behaves_like 'a course-access protected controller'
  end

  context 'in LTI context' do
    let(:request_params) { {canvas_course_id: 'embedded'} }
    before do
      session['canvas_course_id'] = canvas_course_id
    end
    it_behaves_like 'a course-access protected controller'
  end

end
