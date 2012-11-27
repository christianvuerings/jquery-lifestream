class AuthController < ApplicationController

  before_filter :authenticate

  def app_id
    nil
  end

  def get_client(final_redirect = "")
    nil
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
    else
      Rails.logger.debug "Deleting #{app_id} token for user #{session[:user_id]}"
      Oauth2Data.delete_all(:uid => session[:user_id], :app_id => app_id)
    end

    expire_feeds

    final_redirect = params[:state] || "/profile"
    final_redirect = Base64.decode64 final_redirect
    redirect_to final_redirect
  end

  def remove_authorization
    Rails.logger.debug "Deleting #{app_id} token for user #{session[:user_id]}"
    Oauth2Data.delete_all(:uid => session[:user_id], :app_id => app_id)
    expire_feeds
    render :nothing => true, :status => 204
  end

  def expire_feeds
    MyCourseSites.expire session[:user_id]
    # TODO also expire /api/my/status feed
  end

end