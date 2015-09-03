describe GoogleApps::CredentialStore do

  context '#fake' do
    let(:client_id) { Settings.google_proxy.client_id }
    let(:client_secret) { Settings.google_proxy.client_secret }
    let(:scope) { Settings.google_proxy.scope }
    let(:oauth2_data) {
      {
        :access_token => "access_token-#{rand(999999)}",
        :refresh_token => "refresh_token-#{rand(999999)}",
        :expiration_time => 1
      }
    }

    context 'uid has access and refresh token in the database' do
      let(:uid) { random_id }
      let(:store) { GoogleApps::CredentialStore.new(uid) }
      before {
        allow(User::Oauth2Data).to receive(:get).with(uid, GoogleApps::Proxy::APP_ID).and_return oauth2_data
      }

      it 'should load default calcentral credentials' do
        c = store.load_credentials
        expect(c[:client_id]).to eq client_id
        expect(c[:client_secret]).to eq client_secret
        expect(c[:token_credential_uri]).to_not be_nil
        expect(c[:access_token]).to eq oauth2_data[:access_token]
        expect(c[:refresh_token]).to eq oauth2_data[:refresh_token]
        expect(c[:expires_in]).to_not be_nil
        expect(c[:issued_at]).to_not be_nil
        expect(c[:scope]).to eq scope
      end
    end

    context 'options' do
      let(:user_does_not_exist) { random_id }
      let(:store) { GoogleApps::CredentialStore.new(user_does_not_exist, options) }
      before {
        allow(User::Oauth2Data).to receive(:get).with(user_does_not_exist, GoogleApps::Proxy::APP_ID).and_return({})
      }

      context 'override access and refresh token' do
        let(:options) {
          {
            'access_token' => "access_token_#{DateTime.now.strftime('%m/%d/%Y at %I:%M%p')}",
            'refresh_token' => "refresh_token_#{DateTime.now.strftime('%m/%d/%Y at %I:%M%p')}"
          }
        }

        it 'should not load credentials when UID not found' do
          expect(store.load_credentials).to be_nil
        end
      end

      context 'Google auth scope' do
        it 'OEC scope should be a superset of default scope' do
          oec_scope = Settings.oec.google.scope.split(' ')
          default_scope = Settings.google_proxy.scope.split(' ')
          expect(oec_scope).to include *default_scope
        end

      end
    end

    context 'error conditions' do
      it 'should raise error when UID is blank' do
        expect{ GoogleApps::CredentialStore.new('  ') }.to raise_error ArgumentError
      end

      it 'should raise error when client configs are incomplete' do
        store = GoogleApps::CredentialStore.new(random_id, {client_id: 'someClientId', client_secret: ' '})
        expect{ store.load_credentials }.to raise_error
      end
    end
  end

  context '#real', testext: true, :order => :defined do
    let(:options) {
      {
        access_token: "access_token_#{DateTime.now.strftime('%m/%d/%Y at %I:%M%p')}",
        refresh_token: "refresh_token_#{DateTime.now.strftime('%m/%d/%Y at %I:%M%p')}",
        issued_at: 1440628381,
        expires_in: 3600,
        app_data: 'johndoe@berkeley.edu'
      }
    }

    before do
      @uid = 99999.to_s
      @app_id = GoogleApps::Proxy::APP_ID
      existing_data = User::Oauth2Data.get(@uid, @app_id)
      raise 'The random and very large id matches real data. Abort!' if existing_data.any?
      # Values in options hash will be written to the database
      GoogleApps::CredentialStore.new(@uid, options).write_credentials options
    end

    after do
      User::Oauth2Data.remove(@uid, @app_id)
    end

    it 'should find no match in oauth2_data' do
      c = GoogleApps::CredentialStore.new(@uid).load_credentials
      expect(c).to_not be_nil
      expect(c[:access_token]).to eq options[:access_token]
      expect(c[:refresh_token]).to eq options[:refresh_token]
      expect(c[:expiration_time]).to_not be_nil
      expect(c[:expires_in]).to eq 3600
      expect(c[:client_id]).to eq Settings.google_proxy.client_id
      expect(c[:client_secret]).to eq Settings.google_proxy.client_secret
      expect(c[:scope]).to eq Settings.google_proxy.scope
    end
  end

end
