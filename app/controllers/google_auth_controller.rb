require 'google/api_client'

class GoogleAuthController < ApplicationController
  include ClassLogger

  before_filter :check_google_access
  before_filter :authenticate
  respond_to :json

  def request_authorization
    expire
    final_redirect = params[:final_redirect] || '/'
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
      User::Oauth2Data.update_google_email! session[:user_id]
    else
      logger.warn "Deleting #{app_id} access token for user #{session[:user_id]} because auth callback had an error. Error: #{params[:error]}"
      User::Oauth2Data.remove(session[:user_id], app_id)
    end

    expire

    if (final_redirect = params[:state])
      redirect_to Base64.decode64(final_redirect)
    else
      redirect_to url_for_path('/')
    end
  end

  def remove_authorization
    logger.warn "Deleting #{app_id} access token for user #{session[:user_id]} at the user's request."
    GoogleApps::Revoke.new(user_id: session[:user_id]).revoke
    User::Oauth2Data.remove(session[:user_id], app_id)
    expire
    render :nothing => true, :status => 204
  end

  def dismiss_reminder
    result = false
    if (!GoogleApps::Proxy.access_granted? session[:user_id])
      result = User::Oauth2Data.dismiss_google_reminder(session[:user_id])
    end
    User::Api.expire(session[:user_id])
    render json: {:result => result}
  end

  def expire
    Cache::UserCacheExpiry.notify session[:user_id]
  end

  def app_id
    GoogleApps::Proxy::APP_ID
  end

  def get_client(final_redirect = '', force_domain = true)
    google_client = Google::APIClient.new(options={:application_name => 'CalCentral', :application_version => 'v1', :retries => 3})
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

end
