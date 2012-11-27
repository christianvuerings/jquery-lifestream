require 'signet/oauth_2/client'

class CanvasOauth2Controller < ApplicationController

  def get_client(final_redirect = "")
    Signet::OAuth2::Client.new(
        :authorization_uri => Settings.canvas_proxy.authorization_uri,
        :token_credential_uri => Settings.canvas_proxy.token_credential_uri,
        :client_id => Settings.canvas_proxy.client_id,
        :client_secret => Settings.canvas_proxy.client_secret,
        :redirect_uri => url_for(
            :only_path => false,
            :controller => 'canvasOauth2',
            :action => "handle_callback",
            :state => Base64.encode64(final_redirect))
    )
  end

  def request_authorization
    final_redirect = params[:final_redirect] || "/profile"
    client = get_client final_redirect
    url = client.authorization_uri.to_s
    Rails.logger.debug "Initiating Oauth2 authorization request for user #{session[:user_id]} - redirecting to #{url}"
    redirect_to url
  end

  def handle_callback
    client = get_client
    Rails.logger.debug "Handling Oauth2 authorization callback for user #{session[:user_id]}, fetching token from #{client.token_credential_uri}"
    if params[:code]
      client.code = params[:code]
      token_response = client.fetch_access_token
      Rails.logger.debug "handle_callback params = #{params}"
      oauth2 = Oauth2Data.where(
          uid: session[:user_id],
          app_id: CanvasProxy::APP_ID).first_or_initialize
      oauth2.access_token = token_response["access_token"]
      Rails.logger.debug "Saving Canvas token for user #{session[:user_id]}"
      oauth2.save
    else
      Rails.logger.debug "Deleting Canvas token for user #{session[:user_id]}"
      Oauth2Data.delete_all(:uid => session[:user_id], :app_id => CanvasProxy::APP_ID)
    end
    MyCourseSites.expire session[:user_id]
    final_redirect = params[:state] || "/profile"
    final_redirect = Base64.decode64 final_redirect
    redirect_to final_redirect
  end

end
