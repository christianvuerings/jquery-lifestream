describe Canvas::SisCourse do
  let(:user_id)       { Settings.canvas_proxy.test_user_id }
  let(:sis_course_id) { 'CRS:STAT-5432-2013-D-757999' }
  subject             { Canvas::SisCourse.new(:user_id => user_id, :sis_course_id => sis_course_id) }
  it                  { should respond_to(:sis_course_id) }

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
        expect(Canvas::SisCourse).to receive(:fetch_from_cache).and_return(cached: 'hash')
        course = subject.course
        expect(course[:cached]).to eq 'hash'
      end

      it 'bypasses cache when cache option is false' do
        expect(Canvas::SisCourse).not_to receive(:fetch_from_cache)
        course = subject.course(cache: false)[:body]
        expect(course['id']).to eq 1121
        expect(course['account_id']).to eq 128847
        expect(course['sis_course_id']).to eq 'CRS:STAT-5432-2013-D-757999'
        expect(course['term']).to be_an_instance_of Hash
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

  context 'when requesting canvas course id' do
    it 'returns canvas course id' do
      expect(subject.canvas_course_id).to eq 1121
    end
  end

end
