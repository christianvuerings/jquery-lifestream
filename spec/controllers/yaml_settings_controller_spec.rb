describe YamlSettingsController do

  before(:each) do
    @user_id = rand(99999).to_s
    session['user_id'] = @user_id
    expect(Rails.env).to receive(:production?).at_least(1).times.and_return true
    expect(User::Auth).to receive(:where).and_return [user_auth]
    # allow(Settings.features).to receive(:reauthentication).and_return true
  end

  context 'unauthorized user' do
    let(:user_auth) { User::Auth.new(uid: @user_id, is_superuser: false, active: true) }

    it 'should not allow non-admin users to reload settings' do
      expect(Kernel).to_not receive(:const_set)
      get :reload, { :format => 'json' }
      expect(response.status).to eq 403
      expect(response.body.strip).to eq ''
    end
  end

  context 'authorized user' do
    let(:user_auth) { User::Auth.new(uid: @user_id, is_superuser: true, active: true) }
    before {
      settings = OpenStruct.new(
        {
          logger: OpenStruct.new(
            {
              level: log_level
            }
          )
        }
      )
      expect(CalcentralConfig).to receive(:load_settings).and_return(settings)
    }

    context 'corrupt settings' do
      let(:log_level) { 'invalid_log_level' }

      it 'should abort the reload action if settings are corrupt' do
        get :reload, { :format => 'json' }
        expect(response.status).to eq 400
      end
    end

    context 'valid settings' do
      let(:log_level) { 2 }

      it 'should succeed in changing the log level' do
        allow(Rails.logger).to receive(:level).and_return 1
        get :reload, { :format => 'json' }
        expect(response.status).to eq 200
        json = JSON.parse response.body
        expect(json['reloaded']).to be true
      end
    end
  end

end
