describe Canvas::CourseEnrollments do

  let(:uid)               { rand(99999).to_s }
  let(:canvas_user_id)    { rand(99999) }
  let(:canvas_course_id)  { rand(99999) }
  let(:add_enrollment_response_body)  { '{
      "id":20959,
      "root_account_id":90242,
      "course_id":11611,
      "course_section_id":1311,
      "user_id":1234567,
      "associated_user_id":null,
      "enrollment_state":"active",
      "start_at":null,
      "end_at":null,
      "type":"TeacherEnrollment",
      "role":"Owner",
      "role_id":12,
      "limit_privileges_to_course_section":false,
      "last_activity_at":null,
      "sis_import_id":null,
      "sis_course_id":"PROJ:7b3af2d189adba23",
      "course_integration_id":null,
      "sis_section_id":null,
      "section_integration_id":null,
      "html_url":"https://ucberkeley.beta.instructure.com/courses/11611/users/1234567",
      "created_at":"2014-02-03T21:34:38Z",
      "updated_at":"2014-02-03T21:34:38Z"
    }'
  }
  subject { Canvas::CourseEnrollments.new(:user_id => uid, :canvas_course_id => canvas_course_id) }

  context 'when initializing' do
    it 'raises exception if canvas course id option not present' do
      expect { Canvas::CourseEnrollments.new(:user_id => uid) }.to raise_error(ArgumentError, 'Canvas Course ID option required')
    end
  end

  context 'when enrolling user into canvas course' do
    before { subject.on_request(method: :post).set_response(status: 200, body: add_enrollment_response_body) }

    it 'raises exception if canvas_user_id is not an integer' do
      expect { subject.enroll_user('not_an_integer', 'TaEnrollment', 'active', false) }.to raise_error(NoMethodError, 'undefined method `to_int\' for "not_an_integer":String')
    end

    it 'raises exception if enrollment_type is not a string' do
      expect { subject.enroll_user(canvas_user_id, 1234, 'active', false) }.to raise_error(NoMethodError, 'undefined method `to_str\' for 1234:Fixnum')
    end

    it 'raises exception if enrollment state is not a string' do
      expect { subject.enroll_user(canvas_user_id, 'TaEnrollment', 1234, false) }.to raise_error(NoMethodError, 'undefined method `to_str\' for 1234:Fixnum')
    end

    it 'raises exception if enrollment type string is not valid' do
      expect { subject.enroll_user(canvas_user_id, 'AssistantEnrollment', 'active', false) }.to raise_error(ArgumentError, 'Enrollment type argument \'AssistantEnrollment\', must be StudentEnrollment, TeacherEnrollment, TaEnrollment, ObserverEnrollment, or DesignerEnrollment')
    end

    it 'raises exception if enrollment state is not valid' do
      expect { subject.enroll_user(canvas_user_id, 'TaEnrollment', 'inactive', false) }.to raise_error(ArgumentError, 'Enrollment state argument \'inactive\', must be active or invited')
    end

    it 'raises exception if notification flag is not true or false' do
      expect { subject.enroll_user(canvas_user_id, 'TaEnrollment', 'active', 'not true or false') }.to raise_error(ArgumentError, 'Notification flag must be a Boolean')
      expect { subject.enroll_user(canvas_user_id, 'TaEnrollment', 'active', 0) }.to raise_error(ArgumentError, 'Notification flag must be a Boolean')
      expect { subject.enroll_user(canvas_user_id, 'TaEnrollment', 'active', 1) }.to raise_error(ArgumentError, 'Notification flag must be a Boolean')
    end

    it 'raises exception if enrollment type string is not valid' do
      expect { subject.enroll_user(canvas_user_id, 'AssistantEnrollment', 'active', false) }.to raise_error(ArgumentError, 'Enrollment type argument \'AssistantEnrollment\', must be StudentEnrollment, TeacherEnrollment, TaEnrollment, ObserverEnrollment, or DesignerEnrollment')
    end

    it 'raises exception if enrollment state is not valid' do
      expect { subject.enroll_user(canvas_user_id, 'TaEnrollment', 'inactive', false) }.to raise_error(ArgumentError, 'Enrollment state argument \'inactive\', must be active or invited')
    end

    it 'returns confirmation of enrollment' do
      response = subject.enroll_user(canvas_user_id, 'TaEnrollment', 'active', false, :role_id => 12)[:body]
      expect(response['id']).to eq 20959
      expect(response['root_account_id']).to eq 90242
      expect(response['user_id']).to eq 1234567
      expect(response['course_id']).to eq 11611
      expect(response['course_section_id']).to eq 1311
      expect(response['enrollment_state']).to eq 'active'
      expect(response['role']).to eq 'Owner'
      expect(response['role_id']).to eq 12
    end
  end
end
