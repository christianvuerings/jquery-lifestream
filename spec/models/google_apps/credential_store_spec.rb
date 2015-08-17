describe GoogleApps::CredentialStore do

  it 'should load default calcentral credentials' do
    store = GoogleApps::CredentialStore.new
    credentials = store.load_credentials
    expect(credentials[:client_id]).to_not be_nil
    expect(credentials[:token_credential_uri]).to_not be_nil
  end

  it 'should load custom credentials' do
    store = GoogleApps::CredentialStore.new 'oec'
    credentials = store.load_credentials
    expect(credentials[:client_id]).to_not be_nil
    expect(credentials[:token_credential_uri]).to_not be_nil
  end

  it 'should return nil when no such key mapping exists' do
    store = GoogleApps::CredentialStore.new 'no_such_key'
    expect(store.load_credentials).to be_nil
  end

end
