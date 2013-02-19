class SessionsController < ApplicationController

  def lookup
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth['uid']
    Calcentral::USER_CACHE_WARMER.warm session[:user_id]
    redirect_to '/dashboard', :notice => "Signed in!"
  end

  def assume
    return redirect_to '/' unless valid_params?(session[:user_id], params[:uid])
    if UserAuth.is_superuser?(session[:user_id]) || UserAuth.can_act_as?(session[:user_id], params[:uid])
      session[:original_user_id] = session[:user_id] unless session[:original_user_id]
      session[:user_id] = params[:uid]
    end
    redirect_to '/dashboard', :notice => "Assuming user: #{session[:user_id]}"
  end

  def unassume
    return redirect_to '/' unless session[:user_id] && session[:original_user_id]
    #To avoid any potential stale data issues, we might have to be aggressive with cache invalidation.
    ["pseudo_#{session[:user_id]}", session[:user_id]].each do |cache_key|
      Calcentral::USER_CACHE_EXPIRATION.notify cache_key
    end
    session[:user_id] = session[:original_user_id]
    redirect_to '/dashboard', :notice => "Restoring session as user: #{session[:user_id]}"
  end

  def destroy
    Calcentral::USER_CACHE_EXPIRATION.notify session[:user_id]
    reset_session
    redirect_to "#{Settings.cas_logout_url}?url=#{CGI.escape(request.protocol + request.host_with_port)}"
  end

  def new
    redirect_to '/auth/cas'
  end

  def failure
    redirect_to root_url, :status => 401, :alert => "Authentication error: #{params[:message].humanize}"
  end

  private

  def valid_params?(user_uid, act_as_uid)
    return false unless user_uid && act_as_uid

    # Ensure that uids are numeric
    begin
      [user_uid, act_as_uid].each do |param|
        Integer(param, 10)
      end
    rescue ArgumentError
        return false
    end

    # Make sure someone has logged in already before assuming their identify
    # Also useful to enforce in the testing scenario due to the redirect to the settings page.
    return UserData.where(:uid => act_as_uid).first
  end

end
