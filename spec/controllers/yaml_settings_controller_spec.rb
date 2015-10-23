describe YamlSettingsController do

  before(:each) do
    @user_id = rand(99999).to_s
    session['user_id'] = @user_id
    expect(Rails.env).to receive(:production?).at_least(1).times.and_return true
    expect(User::Auth).to receive(:where).and_return [user_auth]
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

    context 'Kernel raises error' do
      it 'should abort the reload action if settings are corrupt' do
        Rails.logger.warn 'EXPECT this test to generate RuntimeError in logs'
        expect(Kernel).to receive(:const_set).with(anything, anything).and_raise RuntimeError
        get :reload, { :format => 'json' }
        expect(response.status).to eq 500
      end
    end

    context 'valid settings' do
      context 'settings change not detected' do
        it 'should warn user of a possible problem' do
          get :reload, { :format => 'json' }
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['message']).to include 'Warning: No change detected in feature flags'
        end
      end

      context 'settings change detected' do
        before {
          Settings.features.textbooks = !Settings.features.textbooks
        }

        it 'should succeed' do
          get :reload, { :format => 'json' }
          expect(response.status).to eq 200
          json = JSON.parse response.body
          expect(json['message']).to include 'Settings reloaded'
        end
      end
    end
  end

end
