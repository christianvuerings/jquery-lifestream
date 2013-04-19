class ApplicationController < ActionController::Base
  protect_from_forgery
  after_filter :access_log

  def authenticate
    redirect_to login_url unless session[:user_id]
  end

  # override of Rails default behavior:
  # reset session AND return 401 when CSRF token validation fails
  def handle_unverified_request
    reset_session
    render :nothing => true, :status => 401
  end

  # Rails url_for defaults the protocol to "request.protocol". But if SSL is being
  # provided by Apache or Nginx, the reported protocol will be "http://". To fix
  # callback URLs, we need to override.
  def default_url_options
    if defined?(Settings.application.protocol) && !Settings.application.protocol.blank?
      logger.debug("Setting default URL protocol to #{Settings.application.protocol}")
      {protocol: Settings.application.protocol}
    else
      {}
    end
  end

  def clear_cache
    # Only super-users are allowed to clear caches in production.
    if Rails.env.production? && !UserAuth.is_superuser?(session[:user_id])
      return render :nothing => true, :status => 401
    end
    Rails.logger.info "Clearing all cache entries"
    Rails.cache.clear
    render :nothing => true, :status => 204
  end

  private

  def access_log
    line = "ACCESS_LOG #{request.env["REMOTE_ADDR"]} #{request.request_method} #{request.fullpath} #{status}"
    if session[:original_user_id]
      line += " uid=#{session[:original_user_id]}_acting_as_uid=#{session[:user_id]}"
    else
      line += " uid=#{session[:user_id]}"
    end
    line += " class=#{self.class.name} action=#{params["action"]} view=#{view_runtime}ms db=#{db_runtime}ms"
    logger.warn line
  end

end
