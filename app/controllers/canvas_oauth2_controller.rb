require 'signet/oauth_2/client'

class CanvasOauth2Controller < ApplicationController

  def get_client
    Signet::OAuth2::Client.new(
        :authorization_uri => Settings.canvas_proxy.authorization_uri,
        :token_credential_uri => Settings.canvas_proxy.token_credential_uri,
        :client_id => Settings.canvas_proxy.client_id,
        :client_secret => Settings.canvas_proxy.client_secret,
        :redirect_uri => url_for(:only_path => false, :controller => 'canvasOauth2', :action => "handle_callback")
    )
  end

  def request_authorization
    client = get_client
    url = client.authorization_uri.to_s
    Rails.logger.debug "Initiating Oauth2 authorization request for user #{session[:user_id]} - redirecting to #{url}"
    redirect_to url
  end

  def handle_callback
    client = get_client
    Rails.logger.debug "Handling Oauth2 authorization callback for user #{session[:user_id]}, fetching token from #{client.token_credential_uri}"
    client.code = request.parameters[:code]
    token_response = client.fetch_access_token
    oauth2 = Oauth2Data.where(
        uid: session[:user_id],
        app_id: "canvas").first_or_initialize
    oauth2.access_token = token_response["access_token"]
    oauth2.save
    MyCourseSites.expire session[:user_id]
    redirect_to "/dashboard"
  end

end
