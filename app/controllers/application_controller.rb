class ApplicationController < ActionController::Base
  include Pundit
  protect_from_forgery
  before_filter :get_settings, :initialize_calcentral_config
  after_filter :access_log
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Disable most of the default headers provided by secure_headers gem, leaving just x-frame for now
  # http://rubydoc.info/gems/secure_headers/0.5.0/frames
  # Rails 4 will DENY X-Frame by default
  ensure_security_headers
  skip_before_filter :set_csp_header, :set_hsts_header, :set_x_content_type_options_header, :set_x_xss_protection_header

  def authenticate
    redirect_to login_url unless session[:user_id]
  end

  def current_user
    @current_user ||= UserAuth.get(session[:user_id])
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
      Rails.logger.debug("Setting default URL protocol to #{Settings.application.protocol}")
      {protocol: Settings.application.protocol}
    else
      {}
    end
  end

  def clear_cache
    authorize(current_user, :can_clear_cache?)
    Rails.logger.info "Clearing all cache entries"
    Rails.cache.clear
    render :nothing => true, :status => 204
  end

  def ping
    # IST's nagios and our check-alive.sh script use this endpoint to tell whether the server's up.
    # Don't modify its content unless you have general agreement that it's necessary to do so.
    ping_state = do_ping
    if ping_state
      render :json => {
        :server_alive => true
      }.to_json
    else
      render :nothing => true, :status => 503
    end
  end

  def user_not_authorized
    render :nothing => true, :status => 401
  end

  private

  def do_ping
    # rate limit so we don't check server status excessively often
    Rails.cache.fetch(
      "server_ping_#{ServerRuntime.get_settings["hostname"]}",
      :expires_in => 30.seconds) {
      if !UserData.database_alive?
        raise "CalCentral database is currently unavailable"
      end
      if !CampusData.database_alive?
        raise "Campus database is currently unavailable"
      end
      true
    }
  end

  def get_settings
    @server_settings = ServerRuntime.get_settings
  end

  def initialize_calcentral_config
    @calcentral_config = {
      "application_version" => ServerRuntime.get_settings["versions"]["application"],
      "client_hostname" => ServerRuntime.get_settings["hostname"],
      "google_analytics_id" => Settings.google_analytics_id,
      "sentry_url" => Settings.sentry_url
    }.to_json.html_safe
  end

  def access_log
    # HTTP_X_FORWARDED_FOR is the client's IP when we're behind Apache; REMOTE_ADDR otherwise
    remote = request.env["HTTP_X_FORWARDED_FOR"] || request.env["REMOTE_ADDR"]
    line = "ACCESS_LOG #{remote} #{request.request_method} #{request.filtered_path} #{status}"
    if session[:original_user_id]
      line += " uid=#{session[:original_user_id]}_acting_as_uid=#{session[:user_id]}"
    else
      line += " uid=#{session[:user_id]}"
    end
    line += " class=#{self.class.name} action=#{params["action"]} view=#{view_runtime}ms db=#{db_runtime}ms"
    logger.warn line
  end

end
