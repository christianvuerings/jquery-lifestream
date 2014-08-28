class AuthController < ApplicationController
  include ActiveRecordHelper
  include ClassLogger

  before_filter :authenticate

  def app_id
    nil
  end

  def get_client(final_redirect = '', force_domain = true)
    nil
  end

  def connected_token_callback(uid)
    nil
  end

  def request_authorization
    expire
    final_redirect = params[:final_redirect] || "/"
    if params[:force_domain].present? && params[:force_domain] == 'false'
      client = get_client(final_redirect, force_domain = false)
    end
    client ||= get_client final_redirect
    url = client.authorization_uri.to_s
    logger.debug "Initiating Oauth2 authorization request for user #{session[:user_id]} - redirecting to #{url}"
    redirect_to url
  end

  def handle_callback
    client = get_client
    logger.debug "Handling Oauth2 authorization callback for user #{session[:user_id]}"
    if params[:code] && params[:error].blank?
      client.code = params[:code]
      client.fetch_access_token!
      logger.warn "Saving #{app_id} access token for user #{session[:user_id]}"
      User::Oauth2Data.new_or_update(
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
      logger.warn "Deleting #{app_id} access token for user #{session[:user_id]} because auth callback had an error. Error: #{params[:error]}"
      User::Oauth2Data.remove(session[:user_id], app_id)
    end

    expire

    if (final_redirect = params[:state])
      redirect_to Base64.decode64(final_redirect)
    else
      redirect_to url_for_path("/")
    end
  end

  def remove_authorization
    logger.warn "Deleting #{app_id} access token for user #{session[:user_id]} at the user's request."
    User::Oauth2Data.remove(session[:user_id], app_id)
    expire
    render :nothing => true, :status => 204
  end

  def expire
    Cache::UserCacheExpiry.notify session[:user_id]
  end

end
