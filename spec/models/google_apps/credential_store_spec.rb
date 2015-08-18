describe GoogleApps::CredentialStore do

  it 'should load default calcentral credentials' do
    custom_token = 'custom_access_token'
    store = GoogleApps::CredentialStore.new(access_token: custom_token)
    credentials = store.load_credentials
    expect(credentials[:client_id]).to_not be_nil
    expect(credentials[:token_credential_uri]).to_not be_nil
    expect(credentials[:access_token]).to eq custom_token
  end

  it 'should load custom credentials' do
    store = GoogleApps::CredentialStore.new(app_name: 'oec')
    credentials = store.load_credentials
    expect(credentials[:client_id]).to_not be_nil
    expect(credentials[:token_credential_uri]).to_not be_nil
    expect(credentials[:access_token]).to_not be_nil
  end

  it 'should return nil when no such key mapping exists' do
    store = GoogleApps::CredentialStore.new(app_name: 'no_such_key')
    expect(store.load_credentials).to be_nil
  end

end
