require "spec_helper"

describe Canvas::SectionEnrollments do

  let(:user_id)                       { 1234567 }
  let(:canvas_section_id)             { 1004321 }
  let(:add_enrollment_response_body)  { '{
      "id":20959382,
      "root_account_id":90242,
      "course_id":1161161,
      "course_section_id":1311313,
      "user_id":1234567,
      "associated_user_id":null,
      "enrollment_state":"active",
      "type":"TaEnrollment",
      "role":"TaEnrollment",
      "limit_privileges_to_course_section":false,
      "last_activity_at":null,
      "html_url":"https://ucberkeley.beta.instructure.com/courses/1161161/users/1234567",
      "created_at":"2014-02-03T21:34:38Z",
      "updated_at":"2014-02-03T21:34:38Z"
    }'
  }
  subject                         { Canvas::SectionEnrollments.new(:section_id => canvas_section_id) }

  context "when initializing" do
    it "raises exception if section id option not present" do
      expect { Canvas::SectionEnrollments.new(:user_id => user_id) }.to raise_error(ArgumentError, "Section ID option required")
    end
  end

  context "when enrolling user into canvas course section" do
    before do
      add_response = double
      add_response.stub(:body).and_return(add_enrollment_response_body)
      subject.stub(:request_uncached).and_return(add_response)
    end

    it "raises exception if user id is not an integer" do
      expect { subject.enroll_user('not_an_integer', 'TaEnrollment', 'active', false) }.to raise_error(ArgumentError, "User ID must be a Fixnum")
    end

    it "raises exception if enrollment type is not a string" do
      expect { subject.enroll_user(user_id, 1234, 'active', false) }.to raise_error(ArgumentError, "Enrollment type must be a String")
    end

    it "raises exception if enrollment state is not a string" do
      expect { subject.enroll_user(user_id, 'TaEnrollment', 1234, false) }.to raise_error(ArgumentError, "Enrollment state must be a String")
    end

    it "raises exception if notification flag is not true or false" do
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'active', 'not true or false') }.to raise_error(ArgumentError, "Notification flag must be a Boolean")
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'active', 0) }.to raise_error(ArgumentError, "Notification flag must be a Boolean")
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'active', 1) }.to raise_error(ArgumentError, "Notification flag must be a Boolean")
    end

    it "raises exception if enrollment type string is not valid" do
      expect { subject.enroll_user(user_id, 'AssistantEnrollment', 'active', false) }.to raise_error(ArgumentError, "Enrollment type argument 'AssistantEnrollment', must be StudentEnrollment, TeacherEnrollment, TaEnrollment, ObserverEnrollment, or DesignerEnrollment")
    end

    it "raises exception if enrollment state is not valid" do
      expect { subject.enroll_user(user_id, 'TaEnrollment', 'inactive', false) }.to raise_error(ArgumentError, "Enrollment state argument 'inactive', must be active or invited")
    end

    it "returns confirmation of enrollment" do
      response = subject.enroll_user(user_id, 'TaEnrollment', 'active', false)
      expect(response).to be_an_instance_of Hash
      expect(response['id']).to eq 20959382
      expect(response['user_id']).to eq 1234567
      expect(response['course_id']).to eq 1161161
      expect(response['course_section_id']).to eq 1311313
      expect(response['enrollment_state']).to eq 'active'
      expect(response['role']).to eq 'TaEnrollment'
    end
  end

  context "when obtaining list of enrollments in canvas course section" do
    it "provides enrollments for canvas course section" do
      enrollments = subject.list_enrollments(:cache => false)
      expect(enrollments).to be_an_instance_of Array
      expect(enrollments.count).to eq 20
      expect(enrollments[0]['id']).to eq 19987364
      expect(enrollments[0]['course_id']).to eq 1050123
      expect(enrollments[0]['course_section_id']).to eq 1004321
      expect(enrollments[0]['root_account_id']).to eq 90242
      expect(enrollments[0]['type']).to eq "StudentEnrollment"
      expect(enrollments[0]['enrollment_state']).to eq "active"
      expect(enrollments[0]['role']).to eq "StudentEnrollment"
      expect(enrollments[0]['user']).to be_an_instance_of Hash
      expect(enrollments[0]['user']['id']).to eq 4000025
      expect(enrollments[0]['user']['name']).to eq "Carlos  J. Dick"
      expect(enrollments[0]['user']['sortable_name']).to eq "Dick, Carlos"
      expect(enrollments[0]['user']['short_name']).to eq "Carlos Dick"
      expect(enrollments[0]['user']['sis_user_id']).to eq "21563990"
      expect(enrollments[0]['user']['sis_login_id']).to eq "754321"
      expect(enrollments[0]['user']['login_id']).to eq "754321"
      expect(enrollments[0]['grades']).to be_an_instance_of Hash
      expect(enrollments[0]['grades']['html_url']).to eq "https://ucberkeley.beta.instructure.com/courses/1050123/grades/4000025"
    end

    it "does not use cache by default" do
      Canvas::SectionEnrollments.should_not_receive(:fetch_from_cache)
      enrollments = subject.list_enrollments
      expect(enrollments).to be_an_instance_of Array
      expect(enrollments.count).to eq 20
    end

    it "uses cache when cache option is true" do
      Canvas::SectionEnrollments.should_receive(:fetch_from_cache).and_return([])
      enrollments = subject.list_enrollments(:cache => true)
      expect(enrollments).to be_an_instance_of Array
      expect(enrollments.count).to eq 0
    end
  end

end
