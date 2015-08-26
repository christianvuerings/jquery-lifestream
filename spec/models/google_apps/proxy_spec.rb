describe GoogleApps::Proxy do

  let(:auth) { GoogleApps::Proxy.new(options).authorization }

  context '#fake' do
    before do
      allow(User::Oauth2Data).to receive(:new).never
    end

    context 'user_id is not nil' do
      let(:options) { { :user_id => random_id, :fake => true } }

      it 'should give precedence to fake access_token during valid user session' do
        expect(auth).to_not be_nil
        expect(auth.client_id).to eq Settings.google_proxy.client_id
        expect(auth.client_secret).to eq Settings.google_proxy.client_secret
        expect(auth.access_token).to eq 'fake_access_token'
        expect(auth.expires_in).to be_nil
        expect(auth.expired?).to be false
      end
    end

    context 'user_id is nil' do
      let(:options) { { :fake => true } }

      it 'should tolerate no session user' do
        expect(auth).to_not be_nil
        expect(auth.access_token).to eq 'fake_access_token'
      end
    end

    context 'test_user tokens' do
      let(:options) { { :fake => true, :access_token => Settings.google_proxy.test_user_access_token,
                        :expiration_time => 0 } }
      it 'should pick up test_user_access_token, minus access_token' do
        expect(auth).to_not be_nil
        expect(auth.client_id).to eq Settings.google_proxy.client_id
        expect(auth.client_secret).to eq Settings.google_proxy.client_secret
        expect(auth.access_token).to eq 'fake_access_token'
      end
    end

  end
end
