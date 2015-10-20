describe MyUpNextController do

  context 'unauthenticated user' do
    it 'returns an empty feed' do
      get :get_feed
      assert_response :success
      expect(JSON.parse(response.body)).to eq({})
    end
  end

  context 'authenticated user' do
    let(:user_id) { rand(99999).to_s }
    before do
      session['user_id'] = user_id
    end
    it 'returns a non-empty feed' do
      get :get_feed
      expect(JSON.parse(response.body)['items']).to be_instance_of(Array)
    end
  end

  context 'viewing-as' do
    let(:user_id) { rand(99999).to_s }
    let(:original_user_id) { rand(99999).to_s }
    before do
      session['user_id'] = user_id
      expect(Settings.google_proxy).to receive(:fake).at_least(:once).and_return(true)
      allow(Settings.features).to receive(:reauthentication).and_return(false)
    end
    it 'should not give a real user a cached censored feed' do
      session['original_user_id'] = original_user_id
      get :get_feed
      expect(JSON.parse(response.body)['items']).to be_empty
      session['original_user_id'] = nil
      get :get_feed
      expect(JSON.parse(response.body)['items']).to be_present
    end
    it 'should not return a cached real-user feed' do
      get :get_feed
      expect(JSON.parse(response.body)['items']).to be_present
      session['original_user_id'] = original_user_id
      get :get_feed
      expect(JSON.parse(response.body)['items']).to be_empty
    end
  end

end
