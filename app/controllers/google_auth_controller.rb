require 'google/api_client'

class GoogleAuthController < AuthController

  respond_to :json

  def app_id
    GoogleApps::Proxy::APP_ID
  end

  def get_client(final_redirect = '', force_domain = true)
    google_client = Google::APIClient.new(options={:application_name => "CalCentral", :application_version => "v1", :retries => 3})
    client = google_client.authorization
    unless force_domain == false
      client.authorization_uri= URI 'https://accounts.google.com/o/oauth2/auth?hd=berkeley.edu'
    end
    client.client_id = Settings.google_proxy.client_id
    client.client_secret = Settings.google_proxy.client_secret
    client.redirect_uri = url_for(
        :only_path => false,
        :controller => 'google_auth',
        :action => 'handle_callback')
    client.state = Base64.encode64 final_redirect
    client.scope = ['profile', 'email', 
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/tasks',
      'https://www.googleapis.com/auth/drive.readonly.metadata',
      'https://mail.google.com/mail/feed/atom/']
    client
  end

  def connected_token_callback(uid)
    User::Oauth2Data.update_google_email! uid
  end

  def dismiss_reminder
    result = false
    if (!GoogleApps::Proxy.access_granted? session[:user_id])
      result = User::Oauth2Data.dismiss_google_reminder(session[:user_id])
    end
    User::Api.expire(session[:user_id])
    render json: {:result => result}
  end

end
