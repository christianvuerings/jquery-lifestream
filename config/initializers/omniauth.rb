Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: "https://#{Settings.cas_server}"
end

# More configurable logging.
OmniAuth.config.logger = Rails.logger

# Ensure https behind Apache.
OmniAuth.config.full_host = lambda do |env|
  # TODO Remove this log statement after testing behind Apache.
  Rails.logger.debug(env)
  if defined?(Settings.application.protocol) && !Settings.application.protocol.blank?
    protocol_host = Settings.application.protocol + env['HTTP_HOST']
  else
    # Fall back to omniauth/strategy default.
    request_uri = URI.parse(env['REQUEST_URI'].gsub(/\?.*$/,''))
    request_uri.path = ''
    protocol_host = request_uri.to_s
  end
  protocol_host
end

if Settings.application.fake_cas && Settings.application.fake_cas_id
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:cas] = OmniAuth::AuthHash.new(
    {
      :provider => 'cas',
      :uid => Settings.application.fake_cas_id
    })
end
