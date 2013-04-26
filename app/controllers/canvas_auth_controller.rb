require 'signet/oauth_2/client'

class CanvasAuthController < AuthController

  def app_id
    CanvasProxy::APP_ID
  end

  def get_client(final_redirect = "")
    Signet::OAuth2::Client.new(
        :authorization_uri => Settings.canvas_proxy.authorization_uri,
        :token_credential_uri => Settings.canvas_proxy.token_credential_uri,
        :client_id => Settings.canvas_proxy.client_id,
        :client_secret => Settings.canvas_proxy.client_secret,
        :redirect_uri => url_for(
            :only_path => false,
            :controller => 'canvas_auth',
            :action => 'handle_callback',
            :state => Base64.encode64(final_redirect))
    )
  end

  def connected_token_callback(uid)
    Oauth2Data.update_canvas_email! uid
  end

end
