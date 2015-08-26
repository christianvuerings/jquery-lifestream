module CampusSolutionsHelperModule

  shared_examples 'a simple proxy that returns errors' do
    before {
      proxy.set_response(status: 506, body: '')
    }
    it 'returns errors properly' do
      expect(subject[:errored]).to eq true
      expect(subject[:statusCode]).to eq 503
    end
  end

  shared_examples 'an unauthenticated user' do
    it 'returns 401' do
      get feed
      expect(response.status).to eq 401
      expect(response.body.strip).to eq ''
    end
  end

  shared_examples 'a successful feed' do
    it 'has some data' do
      session['user_id'] = user
      get feed
      json = JSON.parse(response.body)
      expect(json['statusCode']).to eq 200
      expect(json['feed'][feed_key]).to be
    end
  end

  shared_examples 'a proxy that responds to user error gracefully' do
    it 'returns the right status code and helpful error message' do
      expect(subject[:statusCode]).to eq 400
      expect(subject[:errored]).to eq true
      expect(subject[:feed][:errmsgtext]).to be
    end
  end

  shared_examples 'a proxy that observes a feature flag' do
    before do
      allow(Settings.features).to receive(flag).and_return(false)
    end
    it 'should return an empty feed if the feature is off' do
      expect(subject).to be_empty
    end
  end

  shared_examples 'a proxy that properly observes the profile feature flag' do
    let(:flag) { :cs_profile }
    it_behaves_like 'a proxy that observes a feature flag'
  end

  shared_examples 'a proxy that properly observes the finaid feature flag' do
    let(:flag) { :cs_fin_aid }
    it_behaves_like 'a proxy that observes a feature flag'
  end

end
