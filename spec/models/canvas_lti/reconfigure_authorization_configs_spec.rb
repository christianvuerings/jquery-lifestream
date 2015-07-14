describe CanvasLti::ReconfigureAuthorizationConfigs do
  let(:beta_auth_configs) {
    [
      {
        'id' => 15,
        'position' => 1,
        'auth_type' => 'cas',
        'auth_base' => 'https://auth-test.example.com/cas',
        'log_in_url' => nil,
        'login_handle_name' => 'LDAP UID',
        'unknown_user_url' => ''
      }
    ]
  }
  let(:test_auth_configs) {
    [
      {
        'id' => 16,
        'position' => 1,
        'auth_type' => 'cas',
        'auth_base' => 'https://auth-test.example.com/cas',
        'log_in_url' => nil,
        'login_handle_name' => 'LDAP UID',
        'unknown_user_url' => ''
      }
    ]
  }
  let(:beta_worker) { double(:authorization_configs => beta_auth_configs) }
  let(:test_worker) { double(:authorization_configs => test_auth_configs) }
  let(:canvas_hosts) { ['https://ucb.beta.example.com/', 'https://ucb.test.example.com/'] }
  let(:test_cas_url) { 'https://auth-test.example.com/cas' }

  context 'when CAS authorization base urls match' do
    it 'should not update the CAS Authorization URL' do
      expect(beta_worker).to_not receive(:reset_authorization_config)
      expect(test_worker).to_not receive(:reset_authorization_config)
      allow(Canvas::AuthorizationConfigs).to receive(:new).with(:url_root => canvas_hosts[0]).and_return(beta_worker)
      allow(Canvas::AuthorizationConfigs).to receive(:new).with(:url_root => canvas_hosts[1]).and_return(test_worker)
      CanvasLti::ReconfigureAuthorizationConfigs.reconfigure(test_cas_url, canvas_hosts)
    end
  end

  context 'when CAS authorization base urls do not match' do
    it 'should update the CAS Authorization URL' do
      beta_auth_configs[0]['auth_base'] = 'https://auth.example.com/cas'
      test_auth_configs[0]['auth_base'] = 'https://auth.example.com/cas'
      expect(beta_worker).to receive(:reset_authorization_config).once.and_return(true)
      expect(test_worker).to receive(:reset_authorization_config).once.and_return(true)
      allow(Canvas::AuthorizationConfigs).to receive(:new).with(:url_root => canvas_hosts[0]).and_return(beta_worker)
      allow(Canvas::AuthorizationConfigs).to receive(:new).with(:url_root => canvas_hosts[1]).and_return(test_worker)
      CanvasLti::ReconfigureAuthorizationConfigs.reconfigure(test_cas_url, canvas_hosts)
    end
  end

end
