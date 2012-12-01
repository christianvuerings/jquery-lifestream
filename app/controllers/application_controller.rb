class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate
    redirect_to login_url unless session[:user_id]
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

end
