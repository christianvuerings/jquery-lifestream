describe Canvas::SectionEnrollments do

  let(:user_id) { 1234567 }
  let(:canvas_section_id) { 1004321 }
  let(:ta_role_id) { 1774 }
  subject { Canvas::SectionEnrollments.new(section_id: canvas_section_id) }

  context 'when initializing' do
    it 'raises exception if section id option not present' do
      expect { Canvas::SectionEnrollments.new(user_id: user_id) }.to raise_error(ArgumentError, 'Section ID option required')
    end
  end

  context 'when enrolling user into canvas course section' do
    it 'raises exception if user id is not an integer' do
      expect { subject.enroll_user('not_an_integer', ta_role_id) }.to raise_error(ArgumentError, 'User ID must be a Fixnum')
    end

    it 'raises exception if role ID is not an integer' do
      expect { subject.enroll_user(user_id, 'TaEnrollment') }.to raise_error(ArgumentError, 'Role ID must be a Fixnum')
    end

    it 'returns confirmation of enrollment' do
      response = subject.enroll_user(user_id, ta_role_id)
      expect(response[:statusCode]).to eq 200
      expect(response[:body]).to include({
        'id' => 20618200,
        'user_id' => 1234567,
        'course_id' => 1161161,
        'course_section_id' => 1311313,
        'enrollment_state' => 'active',
        'role' => 'TaEnrollment'
      })
    end

    context 'on request failure' do
      let(:failing_request) { {method: :post} }
      let(:response) { subject.enroll_user(user_id, ta_role_id) }
      it_should_behave_like 'an unpaged Canvas proxy handling request failure'
    end
  end

  context 'when obtaining list of enrollments in canvas course section' do
    it 'provides enrollments for canvas course section' do
      enrollments = subject.list_enrollments(:cache => false)
      expect(enrollments).to have(20).items
      expect(enrollments[0]['id']).to eq 19987364
      expect(enrollments[0]['course_id']).to eq 1050123
      expect(enrollments[0]['course_section_id']).to eq 1004321
      expect(enrollments[0]['root_account_id']).to eq 90242
      expect(enrollments[0]['type']).to eq 'StudentEnrollment'
      expect(enrollments[0]['enrollment_state']).to eq 'active'
      expect(enrollments[0]['role']).to eq 'StudentEnrollment'
      expect(enrollments[0]['role_id']).to eq 1772
      expect(enrollments[0]['user']).to be_an_instance_of Hash
      expect(enrollments[0]['user']['id']).to eq 4000025
      expect(enrollments[0]['user']['name']).to eq 'Carlos  J. Dick'
      expect(enrollments[0]['user']['sortable_name']).to eq 'Dick, Carlos'
      expect(enrollments[0]['user']['short_name']).to eq 'Carlos Dick'
      expect(enrollments[0]['user']['sis_user_id']).to eq '21563990'
      expect(enrollments[0]['user']['sis_login_id']).to eq '754321'
      expect(enrollments[0]['user']['login_id']).to eq '754321'
      expect(enrollments[0]['grades']).to be_an_instance_of Hash
      expect(enrollments[0]['grades']['html_url']).to eq 'https://ucberkeley.beta.instructure.com/courses/1050123/grades/4000025'
    end

    it 'does not use cache by default' do
      Canvas::SectionEnrollments.should_not_receive(:fetch_from_cache)
      enrollments = subject.list_enrollments
      expect(enrollments).to have(20).items
    end

    it 'uses cache when cache option is true' do
      Canvas::SectionEnrollments.should_receive(:fetch_from_cache).and_return(statusCode: 200, body: {cached: 'hash'})
      enrollments = subject.list_enrollments(:cache => true)
      expect(enrollments).to eq(cached: 'hash')
    end

    context 'on request failure' do
      let(:failing_request) { {method: :get} }
      let(:response) { subject.enrollments_response }
      it_should_behave_like 'a paged Canvas proxy handling request failure'
    end
  end

end
