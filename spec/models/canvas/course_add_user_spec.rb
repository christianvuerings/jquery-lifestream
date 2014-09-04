require "spec_helper"

describe Canvas::CourseAddUser do

  let(:canvas_user_profile) {
    {
      "id"=>3332221,
      "name"=>"Bryanna D. Amerson",
      "short_name"=>"Bryanna Amerson",
      "sortable_name"=>"Amerson, Bryanna",
      "sis_user_id"=>"300123",
      "sis_login_id"=>"300123",
      "login_id"=>"300123",
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
    "ldap_uid"=>"1044850",
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
          expect(person.has_key?('student_id')).to be_false
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
          expect(person.has_key?('student_id')).to be_false
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
          expect(person.has_key?('student_id')).to be_false
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
      allow_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(3332221, "StudentEnrollment", 'active', false).and_return(true)
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
      expect(result).to be_true
    end

    it "adds user to canvas course section using canvas user id" do
      expect_any_instance_of(Canvas::SectionEnrollments).to receive(:enroll_user).with(3332221, "StudentEnrollment", 'active', false).and_return(true)
      result = Canvas::CourseAddUser.add_user_to_course_section("260506", "StudentEnrollment", "864215")
      expect(result).to be_true
    end
  end

end
