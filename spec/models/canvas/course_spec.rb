describe Canvas::Course do
  let(:user_id)           { Settings.canvas_proxy.test_user_id }
  let(:canvas_course_id)  { '1121' }
  subject                 { Canvas::Course.new(:user_id => user_id, :canvas_course_id => canvas_course_id) }
  it                      { should respond_to(:canvas_course_id) }

  context 'when requesting course from canvas' do
    context 'if course exists in canvas' do
      it 'returns course hash' do
        course = subject.course[:body]
        expect(course['id']).to eq 1121
        expect(course['account_id']).to eq 128847
        expect(course['sis_course_id']).to eq 'CRS:STAT-5432-2013-D-757999'
        expect(course['course_code']).to eq 'STAT 5432 Fa2013'
        expect(course['name']).to eq 'Whither Statistics'
        expect(course['term']['sis_term_id']).to eq 'TERM:2013-D'
        expect(course['enrollments']).to be_an_instance_of Array
        expect(course['workflow_state']).to eq 'available'
      end

      it 'uses cache by default' do
        expect(Canvas::Course).to receive(:fetch_from_cache).and_return(cached: 'hash')
        course = subject.course
        expect(course[:cached]).to eq 'hash'
      end

      it 'bypasses cache when cache option is false' do
        expect(Canvas::Course).not_to receive(:fetch_from_cache)
        course = subject.course(cache: false)[:body]
        expect(course['id']).to eq 1121
        expect(course['account_id']).to eq 128847
        expect(course['sis_course_id']).to eq 'CRS:STAT-5432-2013-D-757999'
        expect(course['term']['sis_term_id']).to eq 'TERM:2013-D'
        expect(course['course_code']).to eq 'STAT 5432 Fa2013'
        expect(course['name']).to eq 'Whither Statistics'
      end
    end

    context 'if course does not exist in canvas' do
      before { subject.set_response(status: 404, body: '{"errors":[{"message":"The specified resource does not exist."}],"error_report_id":121214508}') }
      it 'returns a 404 response' do
        course = subject.course
        expect(course[:statusCode]).to eq 404
        expect(course[:error]).to be_present
        expect(course).not_to include :body
      end
    end

    context 'on request failure' do
      let(:failing_request) { {method: :get} }
      let(:response) { subject.course }
      it_should_behave_like 'an unpaged Canvas proxy handling request failure'
    end
  end

  context 'when creating course site' do
    let(:api_path) { "accounts/#{canvas_account_id}/courses" }
    let(:course_name) { 'Project X' }
    let(:course_code) { 'Project X' }
    let(:canvas_account_id) { rand(999999).to_s }
    let(:sis_course_id) { 'PROJ:' + rand(999999).to_s }
    let(:term_id) { rand(9999).to_s }
    let(:request_options) do
      {
        :method => :post,
        :body => {
          'account_id' => canvas_account_id,
          'course' => {
            'name' => 'Project X',
            'course_code' => 'Project X',
            'term_id' => term_id,
            'sis_course_id' => sis_course_id
          }
        }
      }
    end
    let(:response_body) do
      {
        'id' => rand(99999),
        'account_id' => canvas_account_id,
        'course_code' => course_code,
        'enrollment_term_id' => term_id,
        'name' => course_name,
        'sis_course_id' => sis_course_id,
        'workflow_state' => 'unpublished'
      }
    end

    it 'formats proper request' do
      expect(subject).to receive(:request_internal).with(api_path, request_options)
      subject.create(canvas_account_id, 'Project X', 'Project X', term_id, sis_course_id)
    end

    it 'returns response object' do
      subject.on_request(uri_matching: api_path, method: :post).set_response(status: 200, body: response_body.to_json)
      result = subject.create(canvas_account_id, 'Project X', 'Project X', term_id, sis_course_id)
      expect(result[:statusCode]).to eq 200
      course_details = result[:body]
      expect(course_details['name']).to eq course_name
      expect(course_details['account_id']).to eq canvas_account_id
      expect(course_details['course_code']).to eq course_code
      expect(course_details['enrollment_term_id']).to eq term_id
      expect(course_details['sis_course_id']).to eq sis_course_id
      expect(course_details['workflow_state']).to eq 'unpublished'
    end

    context 'on request failure' do
      let(:failing_request) { {uri_matching: api_path, method: :post} }
      let(:response) { subject.create(canvas_account_id, 'Project X', 'Project X', term_id, sis_course_id) }
      it_should_behave_like 'an unpaged Canvas proxy handling request failure'
    end
  end

end
