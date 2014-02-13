class SessionsController < ApplicationController
  include ActiveRecordHelper

  def lookup
    auth = request.env["omniauth.auth"]
    continue_login_success auth['uid']
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
    return redirect_to '/' unless valid_params?(session[:user_id], params[:uid])
    Rails.logger.warn "ACT-AS: User #{session[:user_id]} acting as #{params[:uid]} begin"
    session[:original_user_id] = session[:user_id] unless session[:original_user_id]
    session[:user_id] = params[:uid]

    render :nothing => true, :status => 204
  end

  def stop_act_as
    return redirect_to '/' unless session[:user_id] && session[:original_user_id]

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
      reset_session
    ensure
      ActiveRecord::Base.clear_active_connections!
    end
    render :json => {
      :redirect_url => "#{Settings.cas_logout_url}?url=#{CGI.escape(request.protocol + request.host_with_port)}"
    }.to_json
  end

  def new
    # Any parameters appended here to the OmniAuth provider will be
    # returned as parameters to the OmniAuth callback endpoint when
    # authentication completes.
    # The smart_path parameter is used for unauthenticated users to
    # reach a non-public route after a successful CAS login.
    # redirect_to "/auth/cas?smart_path=#{params[:smart_path]}"
    redirect_to "/auth/cas"
  end

  def failure
    params ||= {}
    params[:message] ||= ''
    redirect_to root_url, :status => 401, :alert => "Authentication error: #{params[:message].humanize}"
  end

  private

  # use the smart_path value we pass to omniauth if returned
  def smart_success_path
    #(params[:smart_path].present?) ? params[:smart_path] : '/dashboard'
    '/dashboard'
  end

  def continue_login_success(uid)
    # Force a new CSRF token to be generated on login.
    # http://homakov.blogspot.com.es/2013/06/cookie-forcing-protection-made-easy.html
    session.try(:delete, :_csrf_token)
    if (Integer(uid, 10) rescue nil).nil?
      Rails.logger.warn "FAILED login with CAS UID: #{uid}"
      redirect_to '/uid_error'
    elsif UserApi.is_allowed_to_log_in?(uid)
      session[:user_id] = uid
      redirect_to smart_success_path, :notice => "Signed in!"
    else
      redirect_to '/sorry'
    end
  end

  def valid_params?(user_uid, act_as_uid)
    if user_uid.blank? || act_as_uid.blank?
      Rails.logger.warn "ACT-AS: User #{user_uid} FAILED to login to #{act_as_uid}, either cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      [user_uid, act_as_uid].each do |param|
        Integer(param, 10)
      end
    rescue ArgumentError
        Rails.logger.warn "ACT-AS: User #{user_uid} FAILED to login to #{act_as_uid}, values must be integers"
        return false
    end

    # Make sure someone has logged in already before assuming their identify
    # Also useful to enforce in the testing scenario due to the redirect to the settings page.
    never_logged_in_before = true
    use_pooled_connection {
      never_logged_in_before = UserData.where(:uid => act_as_uid).first.blank?
    }
    if never_logged_in_before && Settings.application.layer == "production"
      Rails.logger.warn "ACT-AS: User #{user_uid} FAILS to login to #{act_as_uid}, #{act_as_uid} hasn't logged in before."
      return false
    end

    auth_user_id = session[:original_user_id] || user_uid
    if !UserAuth.is_superuser?(auth_user_id)
      Rails.logger.warn "ACT-AS: User #{user_uid} FAILS to login to #{act_as_uid}, #{user_uid} isn't a superuser."
      return false
    end

    return true
  end

end
