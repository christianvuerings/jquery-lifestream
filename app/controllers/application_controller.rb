class ApplicationController < ActionController::Base
  protect_from_forgery

  def authenticate
    redirect_to login_url unless session[:user_id]
  end

end
