describe Canvas::AuthorizationConfigs do

  subject { Canvas::AuthorizationConfigs.new(:url_root => 'https://ucb.beta.example.com') }

  context 'when returning a list of authorization configs' do
    it 'should return authorization configs list' do
      list = subject.authorization_configs[:body]
      expect(list).to have(1).items
      expect(list[0]['auth_type']).to eq 'cas'
      expect(list[0]['auth_base']).to eq 'https://auth.example.com/cas'
      expect(list[0]['login_handle_name']).to eq 'LDAP UID'
    end

    context 'on request failure' do
      let(:failing_request) { {method: :get} }
      let(:response) { subject.authorization_configs }
      it_should_behave_like 'a paged Canvas proxy handling request failure'
    end
  end

  context 'when updating an existing authorization config' do
    let(:authorization_config_hash) do
      {
        'id' => 18,
        'auth_type' => 'cas',
        'auth_base' => 'https://auth-test.example.com/cas',
        'login_handle_name' => 'LDAP UID',
        'log_in_url' => nil,
        'unknown_user_url' => '',
        'position' => 1
      }
    end

    it 'should make request to update the specified authorization config' do
      result = subject.reset_authorization_config(authorization_config_hash['id'], authorization_config_hash)[:body]
      expect(result['id']).to eq 18
      expect(result['auth_type']).to eq 'cas'
      expect(result['auth_base']).to eq 'https://auth-test.example.com/cas'
      expect(result['log_in_url']).to eq ''
      expect(result['login_handle_name']).to eq 'LDAP UID'
      expect(result['unknown_user_url']).to eq ''
      expect(result['position']).to eq 1
    end

    context 'on request failure' do
      let(:failing_request) { {method: :put} }
      let(:response) { subject.reset_authorization_config(authorization_config_hash['id'], authorization_config_hash) }
      it_should_behave_like 'an unpaged Canvas proxy handling request failure'
    end
  end

end
