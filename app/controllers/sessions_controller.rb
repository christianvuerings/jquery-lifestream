class SessionsController < ApplicationController

  def lookup
    auth = request.env["omniauth.auth"]
    session[:user_id] = auth['uid']
    Calcentral::USER_CACHE_WARMER.warm session[:user_id]
    redirect_to '/dashboard', :notice => "Signed in!"
  end

  def act_as
    return redirect_to '/' unless valid_params?(session[:user_id], params[:uid])

    session[:original_user_id] = session[:user_id] unless session[:original_user_id]
    session[:user_id] = params[:uid]

    redirect_to '/dashboard', :notice => "Assuming user: #{session[:user_id]}"
  end

  def stop_act_as
    return redirect_to '/' unless session[:user_id] && session[:original_user_id]
    #To avoid any potential stale data issues, we might have to be aggressive with cache invalidation.
    pseudo_user = Calcentral::PSEUDO_USER_PREFIX.concat session[:user_id]
    [pseudo_user, session[:user_id]].each do |cache_key|
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
    if user_uid.blank? || act_as_uid.blank?
      Rails.logger.info "ACT-AS: User #{user_uid} FAILED to login to #{act_as_uid}, either cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      [user_uid, act_as_uid].each do |param|
        Integer(param, 10)
      end
    rescue ArgumentError
        Rails.logger.info "ACT-AS: User #{user_uid} FAILED to login to #{act_as_uid}, values must be integers"
        return false
    end

    # Make sure someone has logged in already before assuming their identify
    # Also useful to enforce in the testing scenario due to the redirect to the settings page.
    if UserData.where(:uid => act_as_uid).first.blank?
      Rails.logger.info "ACT-AS: User #{user_uid} FAILS to login to #{act_as_uid}, #{act_as_uid} hasn't logged in before."
      return false
    end

    if !UserAuth.is_superuser?(session[:user_id])
      Rails.logger.info "ACT-AS: User #{user_uid} FAILS to login to #{act_as_uid}, #{user_uid} isn't a superuser."
      return false
    end

    return true
  end

end
