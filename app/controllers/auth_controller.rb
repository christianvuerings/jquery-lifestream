class AuthController < ApplicationController
  include ActiveRecordHelper

  before_filter :authenticate

  def app_id
    nil
  end

  def get_client(final_redirect = "")
    nil
  end

  def connected_token_callback(uid)
    nil
  end

  def request_authorization
    expire
    final_redirect = params[:final_redirect] || "/settings"
    client = get_client final_redirect
    url = client.authorization_uri.to_s
    Rails.logger.debug "Initiating Oauth2 authorization request for user #{session[:user_id]} - redirecting to #{url}"
    redirect_to url
  end

  def handle_callback
    client = get_client
    Rails.logger.debug "Handling Oauth2 authorization callback for user #{session[:user_id]}, fetching token from #{client.token_credential_uri}"
    if params[:code] && params[:error].blank?
      client.code = params[:code]
      client.fetch_access_token!
      Rails.logger.debug "Saving #{app_id} token for user #{session[:user_id]}"
      Oauth2Data.new_or_update(
          session[:user_id],
          app_id,
          client.access_token.to_s,
          client.refresh_token,
          if client.expires_in.blank?
            0
          else
            client.issued_at.to_i + client.expires_in
          end
      )
      connected_token_callback session[:user_id]
    else
      Rails.logger.debug "Deleting #{app_id} token for user #{session[:user_id]}"
      Oauth2Data.remove(session[:user_id], app_id)
    end

    expire

    final_redirect = params[:state] || "/settings"
    final_redirect = Base64.decode64 final_redirect
    redirect_to final_redirect
  end

  def remove_authorization
    Rails.logger.debug "Deleting #{app_id} token for user #{session[:user_id]}"
    Oauth2Data.remove(session[:user_id], app_id)
    expire
    render :nothing => true, :status => 204
  end

  def expire
    Calcentral::USER_CACHE_EXPIRATION.notify session[:user_id]
  end

end
