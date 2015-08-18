describe GoogleAuthController do

  let(:user_id) { random_id }

  before do
    session['user_id'] = user_id
  end

  describe '#dismiss_reminder' do
    it 'should store a dismiss_reminder key-value when there is no token for a user' do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return false
      post :dismiss_reminder, { :format => 'json' }
      expect(response).to have_http_status :success
      response_body = JSON.parse response.body
      expect(response_body['result']).to be true
    end

    it 'should not store a dismiss_reminder key-value when there is an existing token' do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return true
      post :dismiss_reminder, { :format => 'json' }
      expect(response).to have_http_status :success
      response_body = JSON.parse response.body
      expect(response_body['result']).to be false
    end
  end

  context 'indirectly authenticated' do
    before do
      allow(GoogleApps::Proxy).to receive(:access_granted?).with(user_id).and_return true
      allow(Google::APIClient).to receive(:new).never
    end
    subject do
      post :request_authorization, {}
    end
    context 'viewing as' do
      before do
        session['original_user_id'] = random_id
      end
      it { is_expected.not_to have_http_status :success }
    end
    context 'LTI embedded' do
      before do
        session['lti_authenticated_only'] = true
      end
      it { is_expected.not_to have_http_status :success }
    end
  end

end
