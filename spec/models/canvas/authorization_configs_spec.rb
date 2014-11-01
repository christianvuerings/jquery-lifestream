require "spec_helper"

describe Canvas::AuthorizationConfigs do

  subject { Canvas::AuthorizationConfigs.new(:url_root => 'https://ucb.beta.example.com') }

  context "when returning a list of authorization configs" do
    it "should return authorization configs list" do
      list = subject.authorization_configs
      expect(list).to be_an_instance_of Array
      expect(list.count).to eq 1
      expect(list[0]).to be_an_instance_of Hash
      expect(list[0]['auth_type']).to eq "cas"
      expect(list[0]['auth_base']).to eq "https://auth.example.com/cas"
      expect(list[0]['login_handle_name']).to eq "LDAP UID"
    end

    it "should return empty array if request failed" do
      error_response = double('response', :status => 500, :body => 'Internal Error')
      allow(subject).to receive(:request_uncached).and_return(error_response)
      list = subject.authorization_configs
      expect(list).to eq []
    end
  end

  context "when updating an existing authorization config" do
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

    it "should make request to update the specified authorization config" do
      result = subject.reset_authorization_config(authorization_config_hash['id'], authorization_config_hash)
      expect(result).to be_an_instance_of Hash
      expect(result['id']).to eq 18
      expect(result['auth_type']).to eq "cas"
      expect(result['auth_base']).to eq "https://auth-test.example.com/cas"
      expect(result['log_in_url']).to eq ""
      expect(result['login_handle_name']).to eq "LDAP UID"
      expect(result['unknown_user_url']).to eq ""
      expect(result['position']).to eq 1
    end

    it "should return false if update failed" do
      error_response = double('response', :status => 500, :body => 'Internal Error')
      allow(subject).to receive(:request_uncached).and_return(error_response)
      result = subject.reset_authorization_config(authorization_config_hash['id'], authorization_config_hash)
      expect(result).to eq false
    end
  end

end
