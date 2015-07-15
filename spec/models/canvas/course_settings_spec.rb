describe Canvas::CourseSettings do

  let(:canvas_course_id)    { '1121' }
  subject                   { Canvas::CourseSettings.new(course_id: canvas_course_id) }

  context 'when requesting course settings from canvas' do
    context 'if course exists in canvas' do
      it 'returns course settings hash' do
        settings = subject.settings[:body]
        expect(settings['allow_student_discussion_topics']).to eq true
        expect(settings['allow_student_forum_attachments']).to eq false
        expect(settings['allow_student_discussion_editing']).to eq true
        expect(settings['grading_standard_enabled']).to eq true
        expect(settings['grading_standard_id']).to eq 0
      end

      it 'uses cache by default' do
        expect(Canvas::CourseSettings).to receive(:fetch_from_cache).and_return({cached: 'hash'})
        settings = subject.settings
        expect(settings[:cached]).to eq 'hash'
      end

      it 'bypasses cache when cache option is false' do
        expect(Canvas::CourseSettings).not_to receive(:fetch_from_cache)
        settings = subject.settings(cache: false)[:body]
        expect(settings['allow_student_discussion_topics']).to eq true
      end
    end

    context 'when setting grading scheme' do
      let(:request_options) {
        {
          :method => :put,
          :body => {
            'course' => {
              'grading_standard_id' => Settings.canvas_proxy.default_grading_scheme_id.to_i
            }
          }
        }
      }
      let(:fake_json_body) { {'id' => 1121, 'name' => 'Just another course site'}.to_json }
      let(:fake_response) {
        fake_response = double()
        allow(fake_response).to receive(:body).and_return(fake_json_body)
        fake_response
      }
      it 'sets ucberkeley preferred default scheme by default' do
        course = subject.set_grading_scheme[:body]
        expect(course['id']).to eq 1121
        expect(course['course_code']).to eq 'COMPSCI 9C - LEC 001'
        expect(course['name']).to eq '001-Ruby for Programmers'
      end

      it 'sets specified grading scheme for course site' do
        subject.on_request(uri_matching: subject.api_root, method: :put).set_response(status: 200, body: fake_json_body)
        course = subject.set_grading_scheme(123456)[:body]
        expect(course['name']).to eq 'Just another course site'
      end
    end

    context 'if course does not exist in canvas' do
      before { subject.on_request(method: :get).set_response(status: 404, body: '{"errors":[{"message":"The specified resource does not exist."}],"error_report_id":121214508}') }
      it 'returns a 404 response' do
        settings = subject.settings
        expect(settings[:statusCode]).to eq 404
        expect(settings[:error]).to be_present
        expect(settings).not_to include :body
      end
    end

    context 'on request failure' do
      let(:failing_request) { {method: :get} }
      let(:response) { subject.settings }
      it_should_behave_like 'a Canvas proxy handling request failure'
    end
  end

end
