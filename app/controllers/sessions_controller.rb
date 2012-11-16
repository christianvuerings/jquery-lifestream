class SessionsController < ApplicationController

  def lookup
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth['uid']
    redirect_to '/dashboard', :notice => "Signed in!"
  end

  def destroy
    expire_action(:controller => 'user_api', :action => 'mystatus', :uid => session[:user_id])
    expire_action(:controller => 'user_api', :action => 'userstatus', :uid => session[:user_id])
    reset_session
    redirect_to "#{Settings.cas_logout_url}?url=#{CGI.escape(request.protocol + request.host_with_port)}"
  end

  def new
    redirect_to '/auth/cas'
  end

  def failure
    redirect_to root_url, :status => 401, :alert => "Authentication error: #{params[:message].humanize}"
  end

end
