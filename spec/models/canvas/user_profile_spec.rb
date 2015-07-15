describe Canvas::UserProfile do
  subject { Canvas::UserProfile.new(:canvas_user_id => '3323890') }

  context 'on request failure' do
    let(:failing_request) { {method: :get} }
    let(:response) { subject.user_profile }
    it_should_behave_like 'a Canvas proxy handling request failure'
  end

  context 'when canvas user profile api request is unsuccessful' do
    before { subject.on_request(method: :get).set_response(status: 500, body: 'Internal server error') }
    context 'when providing canvas login id' do
      it 'returns nil' do
        expect(subject.login_id).to be_nil
      end
    end
  end

  context 'when canvas user profile api request succeeds' do
    context 'when providing canvas user profile hash' do
      it 'returns user profile hash' do
        result = subject.get
        expect(result['id']).to eq 3323890
        expect(result['name']).to eq 'STUDENT TEST-300846'
        expect(result['sis_user_id']).to eq 'UID:300846'
        expect(result['sis_login_id']).to eq '300846'
        # note: use login_id, as sis_login_id will eventually be deprecated
        expect(result['login_id']).to eq '300846'
      end
    end

    context 'when providing canvas login id' do
      it 'returns uid string' do
        expect(subject.login_id).to eq '300846'
      end
    end
  end

end
