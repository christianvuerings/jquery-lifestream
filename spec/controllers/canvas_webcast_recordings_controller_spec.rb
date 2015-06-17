shared_examples 'a protected controller' do
  let(:user_id) { rand(99999).to_s }
  before do
    session['user_id'] = user_id
    allow_any_instance_of(Canvas::SisUserProfile).to receive(:get).and_return({
      'id' => user_id
    })
  end
  context 'when user is a member of the course site' do
    before do
      allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).with(user_id).and_return(false)
      expect(Canvas::CourseUser).to receive(:new).with(user_id: user_id, course_id: canvas_course_id).and_return(
        double(course_user: {enrollments: [role: 'StudentEnrollment']})
      )
      expect(Canvas::WebcastRecordings).to receive(:new).with(user_id, anything, canvas_course_id).and_return(
        double(get_feed: {videos: []})
      )
    end
    it 'returns a feed' do
      make_request
      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body)
      expect(response_json['videos']).to eq []
    end
  end
  context 'when user is not in the course site' do
    before do
      allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).with(user_id).and_return(false)
      expect(Canvas::CourseUser).to receive(:new).with(user_id: user_id, course_id: canvas_course_id).and_return(
        double(course_user: nil)
      )
      expect(Canvas::WebcastRecordings).to_not receive(:new)
    end
    it 'returns 403 error' do
      make_request
      expect(response.status).to eq(403)
    end
  end
  context 'when user is a Canvas admin' do
    before do
      allow_any_instance_of(Canvas::Admins).to receive(:admin_user?).with(user_id).and_return(true)
      allow(Canvas::CourseUser).to receive(:new).with(user_id: user_id, course_id: canvas_course_id).and_return(
        double(course_user: nil)
      )
      expect(Canvas::WebcastRecordings).to receive(:new).with(user_id, anything, canvas_course_id).and_return(
        double(get_feed: {videos: []})
      )
    end
    it 'returns a feed' do
      make_request
      expect(response.status).to eq(200)
      response_json = JSON.parse(response.body)
      expect(response_json['videos']).to eq []
    end
  end
end

describe CanvasWebcastRecordingsController do

  let(:canvas_course_id) { rand(99999) }

  context 'in CalCentral context with explicit Canvas course ID' do
    let(:make_request) { get :get_media, canvas_course_id: canvas_course_id.to_s }
    it_behaves_like 'a user authenticated api endpoint'
    it_behaves_like 'a protected controller'
  end

  context 'in LTI context' do
    let(:make_request) { get :get_media, canvas_course_id: 'embedded' }
    before do
      session['canvas_course_id'] = canvas_course_id.to_s
    end
    it_behaves_like 'a protected controller'
  end
end
