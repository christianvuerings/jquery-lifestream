class SessionsController < ApplicationController
  include ActiveRecordHelper

  skip_before_filter :check_reauthentication, :only => [:lookup, :stop_act_as, :destroy]

  def lookup
    auth = request.env["omniauth.auth"]
    if (params[:renew] == 'true')
      cookies[:reauthenticated] = { :value => true, :expires => 8.hours.from_now }
    end
    if cookies[:reauth_admin]
      cookies.delete :reauth_admin
      redirect_to '/ccadmin'
      return
    end
    continue_login_success auth['uid']
  end

  def reauth_admin
    cookies[:reauth_admin] = true
    redirect_to '/auth/cas?renew=true'
  end

  def basic_lookup
    uid = authenticate_with_http_basic do |uid, password|
      uid if password == Settings.developer_auth.password
    end

    if uid
      continue_login_success uid
    else
      failure
    end
  end

  def act_as
    return redirect_to root_path unless valid_params?(current_user, params[:uid])
    Rails.logger.warn "ACT-AS: User #{session[:user_id]} acting as #{params[:uid]} begin"
    session[:original_user_id] = session[:user_id] unless session[:original_user_id]
    session[:user_id] = params[:uid]

    render :nothing => true, :status => 204
  end

  def stop_act_as
    return redirect_to root_path unless session[:user_id] && session[:original_user_id]

    #To avoid any potential stale data issues, we might have to be aggressive with cache invalidation.
    pseudo_user = Calcentral::PSEUDO_USER_PREFIX + session[:user_id]
    [pseudo_user, session[:user_id]].each do |cache_key|
      Calcentral::USER_CACHE_EXPIRATION.notify cache_key
    end
    Rails.logger.warn "ACT-AS: User #{session[:original_user_id]} acting as #{session[:user_id]} ends"
    session[:user_id] = session[:original_user_id]
    session[:original_user_id] = nil

    render :nothing => true, :status => 204
  end

  def destroy
    begin
      delete_reauth_cookies
      reset_session
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
    render :json => {
      :redirectUrl => "#{Settings.cas_logout_url}?url=#{CGI.escape(request.protocol + request.host_with_port)}"
    }.to_json
  end

  def failure
    params ||= {}
    params[:message] ||= ''
    redirect_to root_path, :status => 401, :alert => "Authentication error: #{params[:message].humanize}"
  end

  private

  def smart_success_path
    # the :url parameter is returned by the CAS auth server
    (params[:url].present?) ? params[:url] : url_for_path('/dashboard')
  end

  def continue_login_success(uid)
    # Force a new CSRF token to be generated on login.
    # http://homakov.blogspot.com.es/2013/06/cookie-forcing-protection-made-easy.html
    session.try(:delete, :_csrf_token)
    if (Integer(uid, 10) rescue nil).nil?
      Rails.logger.warn "FAILED login with CAS UID: #{uid}"
      redirect_to url_for_path('/uid_error')
    else
      session[:user_id] = (acting_as?) ? act_as_uid : uid
      redirect_to smart_success_path, :notice => "Signed in!"
    end
  end

  def valid_params?(current_user, act_as_uid)
    if current_user.blank? || act_as_uid.blank?
      Rails.logger.warn "ACT-AS: User #{current_user.uid} FAILED to login to #{act_as_uid}, either cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      [current_user.uid, act_as_uid].each do |param|
        Integer(param, 10)
      end
    rescue ArgumentError
        Rails.logger.warn "ACT-AS: User #{current_user.uid} FAILED to login to #{act_as_uid}, values must be integers"
        return false
    end

    if session[:original_user_id]
      auth_user_id = session[:original_user_id]
    else
      auth_user_id = current_user.uid
    end

    policy = User::Auth.get(auth_user_id).policy
    policy.can_act_as?
  end

end
