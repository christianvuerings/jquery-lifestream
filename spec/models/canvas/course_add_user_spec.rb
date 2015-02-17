require "spec_helper"

describe Canvas::CourseAddUser do
  let(:ldap_uid) { '1044850' }
  let(:canvas_user_id) { 3332221 }
  let(:canvas_user_profile) {
    {
      "id"=>canvas_user_id,
      "name"=>"Bryanna D. Amerson",
      "short_name"=>"Bryanna Amerson",
      "sortable_name"=>"Amerson, Bryanna",
      "sis_user_id"=>ldap_uid,
      "sis_login_id"=>ldap_uid,
      "login_id"=>ldap_uid,
      "avatar_url"=>"https://secure.gravatar.com/avatar/1234567-avatar-50.png",
      "title"=>nil,
      "bio"=>nil,
      "primary_email"=>"test-12345@example.edu"
    }
  }

  let(:canvas_course_sections_list) do
    [
      {"id" => "202184", "name" => "Section One Name", "course_id" => 767330, "sis_section_id" => nil},
      {"id" => "202113", "name" => "Section Two Name", "course_id" => 767330, "sis_section_id" => "SEC:2013-D-12345"}
    ]
  end

  let(:person_hash) { {
    "ldap_uid"=>ldap_uid,
    "first_name"=>"Bryan",
    "last_name"=>"Cranston",
    "email_address"=>"bryan.cranston@example.com",
    "student_id"=>"2212340",
    "affiliations"=>"STUDENT-TYPE-REGISTERED"
  } }

  let(:people_array) {
    people = []
    (0...5).each do |num|
      people << person_hash
    end
    people
  }

  let(:canvas_course_sections_list_response) do
    sections_list_response = double()
    sections_list_response.stub(:body).and_return(canvas_course_sections_list.to_json)
    sections_list_response
  end

  before do
    allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return(canvas_user_profile)
    allow_any_instance_of(Canvas::CourseSections).to receive(:sections_list).and_return(canvas_course_sections_list_response)
  end

  context "when searching for users" do
    it "raises exception if search text is not a string" do
      expect { Canvas::CourseAddUser.search_users({:not => 'a string'}, 'name') }.to raise_error(ArgumentError, "Search text must of type String")
    end

    it "raises exception if search type is not a string" do
      expect { Canvas::CourseAddUser.search_users('John Doe', {:not => 'a string'}) }.to raise_error(ArgumentError, "Search type must of type String")
    end

    it "raises exception if search type is not supported" do
      expect { Canvas::CourseAddUser.search_users('John Doe', 'phone_number') }.to raise_error(ArgumentError, "Search type argument 'phone_number' invalid. Must be name, email, or ldap_user_id")
    end

    context "when searching by name" do
      it "searches users by name" do
        CampusOracle::Queries.should_receive(:find_people_by_name).with('John Doe', Canvas::CourseAddUser::SEARCH_LIMIT).and_return([])
        people = Canvas::CourseAddUser.search_users('John Doe', 'name')
        expect(people).to be_an_instance_of Array
      end

      it "does not include student id in the results" do
        CampusOracle::Queries.should_receive(:find_people_by_name).with('John Doe', Canvas::CourseAddUser::SEARCH_LIMIT).and_return(people_array)
        people = Canvas::CourseAddUser.search_users('John Doe', 'name')
        people.each do |person|
          expect(person).to be_an_instance_of Hash
          expect(person.has_key?('student_id')).to be_falsey
        end
      end
    end

    context "when searching by email" do
      it "searches users by email" do
        CampusOracle::Queries.should_receive(:find_people_by_email).with('johndoe@ber', Canvas::CourseAddUser::SEARCH_LIMIT).and_return([])
        people = Canvas::CourseAddUser.search_users('johndoe@ber', 'email')
        expect(people).to be_an_instance_of Array
      end

      it "does not include student id in the results" do
        CampusOracle::Queries.should_receive(:find_people_by_email).with('johndoe@ber', Canvas::CourseAddUser::SEARCH_LIMIT).and_return([])
        people = Canvas::CourseAddUser.search_users('johndoe@ber', 'email')
        expect(people).to be_an_instance_of Array
        people.each do |person|
          expect(person).to be_an_instance_of Hash
          expect(person.has_key?('student_id')).to be_falsey
        end
      end
    end

    context "when searching by LDAP user id" do
      it "searches users by LDAP user id" do
        CampusOracle::Queries.should_receive(:find_people_by_uid).with('100374').and_return([])
        people = Canvas::CourseAddUser.search_users('100374', 'ldap_user_id')
        expect(people).to be_an_instance_of Array
      end

      it "does not include student id in the results" do
        CampusOracle::Queries.should_receive(:find_people_by_uid).with('100374').and_return([])
        people = Canvas::CourseAddUser.search_users('100374', 'ldap_user_id')
        expect(people).to be_an_instance_of Array
        people.each do |person|
          expect(person).to be_an_instance_of Hash
          expect(person.has_key?('student_id')).to be_falsey
        end
      end
    end
  end

  context "when obtaining course sections list" do
    it "returns list of section ids and names" do
      result = Canvas::CourseAddUser.course_sections_list(767330)
      expect(result).to be_an_instance_of Array
      expect(result.count).to eq 2
      expect(result[0]['id']).to eq "202184"
      expect(result[0]['name']).to eq "Section One Name"
      expect(result[0]['course_id']).to be_nil
      expect(result[0]['sis_section_id']).to be_nil
      expect(result[1]['id']).to eq "202113"
      expect(result[1]['name']).to eq "Section Two Name"
      expect(result[1]['course_id']).to be_nil
      expect(result[1]['sis_section_id']).to be_nil
    end
  end

  context "when adding user to a course section" do
    before do
      allow_any_instance_of(Canvas::UserProvision).to receive(:import_users).with(["260506"]).and_return(true)
      allow_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(canvas_user_id, "StudentEnrollment", 'active', false).and_return(true)
    end

    it "raises exception when ldap_user_id is not a string" do
      expect { Canvas::CourseAddUser.add_user_to_course_section(260506, "StudentEnrollment", "864215") }.to raise_error(ArgumentError, "ldap_user_id must be a String")
    end

    it "raises exception when role is not a string" do
      expect { Canvas::CourseAddUser.add_user_to_course_section("260506", 1, "864215") }.to raise_error(ArgumentError, "role must be a String")
    end

    it "adds user to canvas" do
      expect_any_instance_of(Canvas::UserProvision).to receive(:import_users).with(["260506"]).and_return(true)
      result = Canvas::CourseAddUser.add_user_to_course_section("260506", "StudentEnrollment", "864215")
      expect(result).to be_truthy
    end

    it "adds user to canvas course section using canvas user id" do
      expect_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(canvas_user_id, "StudentEnrollment", 'active', false).and_return(true)
      result = Canvas::CourseAddUser.add_user_to_course_section("260506", "StudentEnrollment", "864215")
      expect(result).to be_truthy
    end
  end

  context "when adding user to a course" do
    let(:enrollment_type) { 'TeacherEnrollment' }
    let(:canvas_course_id) { '864215' }
    let(:enrollment_state) { 'active' }
    let(:owner_role_id) { Settings.canvas_proxy.projects_owner_role_id }
    let(:teacher_role_id) { 5 }
    let(:enroll_user_response) {
      {
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
    let(:enroll_user_with_role_id_response) { enroll_user_response.merge({'role' => 'Owner', 'role_id' => owner_role_id})}
    before do
      allow_any_instance_of(Canvas::SisUserProfile).to receive(:new).with(:user_id => ldap_uid).and_return(double(get: canvas_user_profile))
      allow_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, enrollment_type, enrollment_state, false, {}).and_return(enroll_user_response)
    end

    it "enrolls user to canvas course" do
      expect_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, enrollment_type, enrollment_state, false, {}).and_return(enroll_user_response)
      result = Canvas::CourseAddUser.add_user_to_course(ldap_uid, enrollment_type, canvas_course_id)
      expect(result).to be_an_instance_of Hash
      expect(result['id']).to eq 20959
      expect(result['root_account_id']).to eq 90242
      expect(result['enrollment_state']).to eq 'active'
      expect(result['role']).to eq 'TeacherEnrollment'
      expect(result['role_id']).to eq teacher_role_id
    end

    it "adds user to canvas with custom role id option" do
      expect_any_instance_of(Canvas::CourseEnrollments).to receive(:enroll_user).with(canvas_user_id, enrollment_type, enrollment_state, false, {:role_id => owner_role_id}).and_return(enroll_user_with_role_id_response)
      result = Canvas::CourseAddUser.add_user_to_course(ldap_uid, enrollment_type, canvas_course_id, :role_id => owner_role_id)
      expect(result['root_account_id']).to eq 90242
      expect(result['enrollment_state']).to eq 'active'
      expect(result['role']).to eq 'Owner'
      expect(result['role_id']).to eq owner_role_id
    end
  end

  context "when serving the roles a user may select when adding a new user" do
    let(:no_course_user_roles) { {"teacher"=>false, "student"=>false, "observer"=>false, "designer"=>false, "ta"=>false} }
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

    it "returns all roles when the user is indicated to be a global admin" do
      result = Canvas::CourseAddUser.granting_roles(no_course_user_roles, true)
      expect(result).to eq privileged_roles
    end

    it "returns all roles when the user is a teacher" do
      result = Canvas::CourseAddUser.granting_roles(teacher_course_user_roles)
      expect(result).to eq privileged_roles
    end

    it "returns all roles when the user is an owner" do
      result = Canvas::CourseAddUser.granting_roles(owner_course_user_roles)
      expect(result).to eq privileged_roles
    end

    it "returns all roles when the user is a designer" do
      result = Canvas::CourseAddUser.granting_roles(designer_course_user_roles)
      expect(result).to eq privileged_roles
    end

    it "returns only student and observer roles when the user is only a teachers assistant" do
      result = Canvas::CourseAddUser.granting_roles(ta_course_user_roles)
      expect(result).to eq ta_roles
    end

    it "returns only student and observer roles when the user is only a maintainer" do
      result = Canvas::CourseAddUser.granting_roles(maintainer_course_user_roles)
      expect(result).to eq ta_roles
    end

    it "returns no roles when the user is only a student" do
      result = Canvas::CourseAddUser.granting_roles(student_course_user_roles)
      expect(result).to eq []
    end

    it "returns no roles when the user is only an observer" do
      result = Canvas::CourseAddUser.granting_roles(observer_course_user_roles)
      expect(result).to eq []
    end
  end

end
