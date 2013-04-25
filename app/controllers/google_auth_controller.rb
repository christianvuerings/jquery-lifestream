require 'google/api_client'

class GoogleAuthController < AuthController

  def app_id
    GoogleProxy::APP_ID
  end

  def get_client(final_redirect = "")
    google_client = Google::APIClient.new(options={:application_name => "CalCentral", :application_version => "v1"})
    client = google_client.authorization
    client.client_id = Settings.google_proxy.client_id
    client.client_secret = Settings.google_proxy.client_secret
    client.redirect_uri = url_for(
        :only_path => false,
        :controller => 'google_auth',
        :action => 'handle_callback')
    client.state = Base64.encode64 final_redirect
    client.scope = ['https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/tasks',
      'https://www.googleapis.com/auth/drive.readonly.metadata',
      'https://mail.google.com/mail/feed/atom/']
    client
  end

  def connected_token_callback(uid)
    Oauth2Data.update_google_email! uid
  end

end
