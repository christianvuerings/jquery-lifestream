Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas,
           url: Settings.cas_server,
           service_validate_url: '/samlValidate'
end

# More configurable logging.
OmniAuth.config.logger = Rails.logger

# Ensure https behind Apache.
OmniAuth.config.full_host = lambda do |env|
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

module OmniAuth
  module Strategies
    class CAS
      def login_url(service)
        login_options = { :service => service }
        if request.params['renew']=='true'
          login_options.merge!(:renew=>'true')
        end
        cas_url + append_params( @options.login_url, login_options)
      end
    end
  end
end
