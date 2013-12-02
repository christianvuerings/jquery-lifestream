Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, :url => "https://#{Settings.cas_server}"
end

# More configurable logging.
OmniAuth.config.logger = Rails.logger

if Settings.application.fake_cas && Settings.application.fake_cas_id
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new(
    {
      :provider => 'cas',
      :uid => Settings.application.fake_cas_id
    })
end
