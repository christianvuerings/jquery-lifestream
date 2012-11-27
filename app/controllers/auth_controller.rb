require 'google/api_client'

class AuthController < ApplicationController
  before_filter :authenticate

  def google_request_access
    new_client = init_google_client.authorization.dup
    new_client.state = params[:redirect_url]
    new_client.state ||= Base64.encode64 "/dashboard"
    redirect_to new_client.authorization_uri.to_s, :status => 303
  end

  def google_auth_callback
    new_client = init_google_client.authorization.dup

    redirect_url = Base64.decode64(params[:state]) unless params[:state].blank?
    redirect_url ||= "/dashboard"

    unless params[:error].blank?
      # remove token if access_denied
      Oauth2Data.delete_all(uid: session[:user_id], app_id: "google") if params[:error] == "access_denied"
      return redirect_to redirect_url, :status => 301
    end

    new_client.code = params[:code] if params[:code]
    new_client.fetch_access_token!
    if Oauth2Data.exists?(uid: session[:user_id], app_id: "google")
      Oauth2Data.update_all(
        {
          uid: session[:user_id],
          app_id: "google"
        },
        {
          access_token: new_client.access_token.to_s,
          refresh_token: new_client.refresh_token,
          expiration_time: new_client.issued_at.to_i + new_client.expires_in
        })
    else
      new_entry = Oauth2Data.new(uid: session[:user_id], app_id: "google", access_token: new_client.access_token.to_s,
                                 refresh_token: new_client.refresh_token, expiration_time: new_client.issued_at.to_i + new_client.expires_in)
      new_entry.save
    end

    redirect_to redirect_url, :status => 301
  end

  private
  def init_google_client
    client = Google::APIClient.new
    client.authorization.client_id = Settings.google_proxy.client_id
    client.authorization.client_secret = Settings.google_proxy.client_secret
    client.authorization.redirect_uri = Settings.google_proxy.client_redirect_uri
    client.authorization.scope = ['https://www.googleapis.com/auth/calendar', 'https://www.googleapis.com/auth/tasks']
    client
  end

end