require 'google/api_client'

class AuthController < ApplicationController
  before_filter :authenticate

  def new_google_authorization
    client = Google::APIClient.new
    client.authorization.client_id = Settings.google_proxy.client_id
    client.authorization.client_secret = Settings.google_proxy.client_secret
    client.authorization.redirect_uri = url_for(:only_path => false, :controller => 'auth', :action => "google_auth_callback")
    client.authorization.scope = ['https://www.googleapis.com/auth/userinfo.profile',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/tasks']
    client.authorization
  end

  def google_request_access
    new_auth = new_google_authorization
    new_auth.state = params[:final_redirect]
    new_auth.state ||= "/profile"
    new_auth.state = Base64.encode64 new_auth.state
    redirect_to new_auth.authorization_uri.to_s
  end

  def google_auth_callback
    new_auth = new_google_authorization

    final_redirect = params[:state]
    final_redirect ||= "/profile"
    final_redirect = Base64.decode64 final_redirect

    if !params[:error].blank?
      # remove token if access_denied
      Oauth2Data.delete_all(:uid => session[:user_id], :app_id => GoogleProxy::APP_ID) if params[:error] == "access_denied"
    elsif !params[:code].blank?
      new_auth.code = params[:code]
      new_auth.fetch_access_token!
      Oauth2Data.new_or_update(
        session[:user_id],
        GoogleProxy::APP_ID,
        new_auth.access_token.to_s,
        new_auth.refresh_token,
        new_auth.issued_at.to_i + new_auth.expires_in
      )
    end

    redirect_to final_redirect
  end

end
