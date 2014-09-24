require "spec_helper"
require "support/shared_examples"
require "support/canvas_shared_examples"

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
      { 'first_name' => 'Felix', 'last_name' => 'Gracia', 'email_address' => 'fgracia@example.edu', 'student_id' => '1097826', 'ldap_uid' => '12890', 'affiliations' => 'EMPLOYEE-TYPE-STAFF,STUDENT-STATUS-EXPIRED' },
      { 'first_name' => 'Brian', 'last_name' => 'Spires', 'email_address' => 'brianlspires@example.edu', 'student_id' => '1039872', 'ldap_uid' => '10054', 'affiliations' => 'EMPLOYEE-STATUS-EXPIRED,STUDENT-STATUS-EXPIRED' },
      { 'first_name' => 'Maria', 'last_name' => 'Patterson', 'email_address' => 'mjpatterson@example.edu', 'student_id' => '1002331', 'ldap_uid' => '4883', 'affiliations' => 'STUDENT-TYPE-REGISTERED,EMPLOYEE-TYPE-ACADEMIC' },
    ]
  end

  let(:course_sections_list) do
    [
      {"id" => "202184", "name" => "Section One Name"},
      {"id" => "1237009", "name" => "Section Two Name"}
    ]
  end

  before do
    session[:user_id] = "12345"
    session[:canvas_user_id] = "43232321"
    session[:canvas_course_id] = "767330"
    allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_user_hash)
    allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(true)
    allow(Canvas::CourseAddUser).to receive(:course_sections_list).and_return(course_sections_list)
  end

  context "when serving course user role information" do

    it_should_behave_like "an api endpoint" do
      before { allow(subject).to receive(:course_user_roles).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :course_user_roles }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :course_user_roles }
    end

    context "when session with canvas course user present" do

      context "when user is student" do
        let(:canvas_course_student_hash) { canvas_course_user_hash.merge({'enrollments' => [student_enrollment_hash]}) }
        before do
          allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(false)
          allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_student_hash)
        end
        it "returns course user details" do
          get :course_user_roles
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json['roles']).to be_an_instance_of Hash
          roles = response_json['roles']
          expect(roles).to be_an_instance_of Hash
          expect(roles['globalAdmin']).to be_false
          expect(roles['teacher']).to be_false
          expect(roles['student']).to be_true
          expect(roles['observer']).to be_false
          expect(roles['designer']).to be_false
          expect(roles['ta']).to be_false
        end

        it "returns no granting roles" do
          get :course_user_roles
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json['grantingRoles']).to eq []
        end
      end

      context "when user is teachers assistant" do
        let(:canvas_course_ta_hash) { canvas_course_user_hash.merge({'enrollments' => [ta_enrollment_hash]}) }
        before do
          allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(false)
          allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_ta_hash)
        end

        it "returns course user details" do
          get :course_user_roles
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json['roles']).to be_an_instance_of Hash
          roles = response_json['roles']
          expect(roles).to be_an_instance_of Hash
          expect(roles['globalAdmin']).to be_false
          expect(roles['teacher']).to be_false
          expect(roles['student']).to be_false
          expect(roles['observer']).to be_false
          expect(roles['designer']).to be_false
          expect(roles['ta']).to be_true
        end

        it "returns student and observer granting roles" do
          get :course_user_roles
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

      context "when user is canvas course teacher" do
        let(:canvas_course_teacher_hash) { canvas_course_user_hash.merge({'enrollments' => [teacher_enrollment_hash]}) }
        before do
          allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(false)
          allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(canvas_course_teacher_hash)
        end

        it "returns course user details" do
          get :course_user_roles
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json['roles']).to be_an_instance_of Hash
          roles = response_json['roles']
          expect(roles).to be_an_instance_of Hash
          expect(roles['globalAdmin']).to be_false
          expect(roles['teacher']).to be_true
          expect(roles['student']).to be_false
          expect(roles['observer']).to be_false
          expect(roles['designer']).to be_false
          expect(roles['ta']).to be_false
        end

        it "returns all granting roles" do
          get :course_user_roles
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

      context "when user is canvas account admin" do
        before do
          allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).and_return(true)
          allow_any_instance_of(Canvas::CourseUser).to receive(:request_course_user).and_return(nil)
        end
        it "returns canvas admin user details" do
          get :course_user_roles
          expect(response.status).to eq(200)
          response_json = JSON.parse(response.body)
          expect(response_json['roles']).to be_an_instance_of Hash
          roles = response_json['roles']
          expect(roles).to be_an_instance_of Hash
          expect(roles['globalAdmin']).to be_true
          expect(roles['teacher']).to be_false
          expect(roles['student']).to be_false
          expect(roles['observer']).to be_false
          expect(roles['designer']).to be_false
          expect(roles['ta']).to be_false
        end

        it "returns all granting roles" do
          get :course_user_roles
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

  context "when performing user search" do
    before do
      allow(Canvas::CourseAddUser).to receive(:search_users).and_return(users_found)
    end

    it_should_behave_like "an api endpoint" do
      before { allow(subject).to receive(:search_users).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { get :search_users, search_text: "John Doe", search_type: "name" }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :search_users, search_text: "John Doe", search_type: "name" }
    end

    it_should_behave_like "a canvas course admin authorized api endpoint" do
      let(:make_request) { get :search_users, search_text: "John Doe", search_type: "name" }
    end

    it "returns error if search_text parameter is blank" do
      get :search_users, search_text: "", search_type: "name"
      expect(response.status).to eq(400)
      expect(response.body).to eq "Parameter 'search_text' is blank"
    end

    it "returns error if search_type parameter is not valid" do
      get :search_users, search_text: "John Doe", search_type: "weight"
      expect(response.status).to eq(400)
      expect(response.body).to eq "Parameter 'search_type' is invalid"
    end

    it "returns user search results" do
      expect(Canvas::CourseAddUser).to receive(:search_users).with('John Doe', 'name').and_return(users_found)
      get :search_users, search_text: "John Doe", search_type: "name"
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
      let(:make_request) { get :course_sections }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { get :course_sections }
    end

    it_should_behave_like "a canvas course admin authorized api endpoint" do
      let(:make_request) { get :course_sections }
    end

    it "returns sections for search" do
      get :course_sections
      expect(response.status).to eq(200)
      json_response = JSON.parse(response.body)
      expect(json_response['course_sections']).to be_an_instance_of Array
      expect(json_response['course_sections'].count).to eq 2
      expect(json_response['course_sections'][0]).to be_an_instance_of Hash
      expect(json_response['course_sections'][0]['id']).to eq "202184"
      expect(json_response['course_sections'][0]['name']).to eq "Section One Name"
      expect(json_response['course_sections'][1]).to be_an_instance_of Hash
      expect(json_response['course_sections'][1]['id']).to eq "1237009"
      expect(json_response['course_sections'][1]['name']).to eq "Section Two Name"
    end
  end

  context "when adding user to course" do
    before { allow(Canvas::CourseAddUser).to receive(:add_user_to_course_section).and_return(true) }

    it_should_behave_like "an api endpoint" do
      before { subject.stub(:add_user).and_raise(RuntimeError, "Something went wrong") }
      let(:make_request) { post :add_user, ldap_user_id: "260506", role_id: "StudentEnrollment", section_id: 864215 }
    end

    it_should_behave_like "a user authenticated api endpoint" do
      let(:make_request) { post :add_user, ldap_user_id: "260506", role_id: "StudentEnrollment", section_id: 864215 }
    end

    it_should_behave_like "a canvas course admin authorized api endpoint" do
      let(:make_request) { post :add_user, ldap_user_id: "260506", role_id: "StudentEnrollment", section_id: 864215 }
    end

    context "when role specified is authorized" do
      let(:ta_roles) { [
        {'id' => 'StudentEnrollment', 'name' => 'Student'},
        {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
      ] }
      before { allow(Canvas::CourseAddUser).to receive(:granting_roles).and_return(ta_roles) }

      it "adds user to course section" do
        post :add_user, ldap_user_id: "260506", role_id: "StudentEnrollment", section_id: "864215"
        expect(response.status).to eq(200)
        json_response = JSON.parse(response.body)
        expect(json_response['user_added']).to be_an_instance_of Hash
        expect(json_response['user_added']['ldap_user_id']).to eq "260506"
        expect(json_response['user_added']['role_id']).to eq "StudentEnrollment"
        expect(json_response['user_added']['section_id']).to eq "864215"
      end
    end

    context "when role specified is not authorized" do
      let(:ta_roles) { [
        {'id' => 'StudentEnrollment', 'name' => 'Student'},
        {'id' => 'ObserverEnrollment', 'name' => 'Observer'},
      ] }
      before { allow(Canvas::CourseAddUser).to receive(:granting_roles).and_return(ta_roles) }

      it "denies unauthorized roles" do
        post :add_user, ldap_user_id: "260506", role_id: "TaEnrollment", section_id: "864215"
        expect(response.status).to eq 403
        expect(response.body).to eq " "
      end
    end

  end

end
