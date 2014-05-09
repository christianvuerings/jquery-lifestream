class SessionsController < ApplicationController
  include ActiveRecordHelper, ClassLogger

  skip_before_filter :check_reauthentication, :only => [:lookup, :stop_act_as, :destroy]

  def lookup
    auth = request.env["omniauth.auth"]
    if (params[:renew] == 'true')
      cookies[:reauthenticated] = { :value => true, :expires => 8.hours.from_now }
    end
    continue_login_success auth['uid']
  end

  def reauth_admin
    redirect_to url_for_path("/auth/cas?renew=true&url=/ccadmin")
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

  def destroy
    begin
      delete_reauth_cookie
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
      logger.warn "FAILED login with CAS UID: #{uid}"
      redirect_to url_for_path('/uid_error')
    else
      session[:user_id] = (acting_as?) ? act_as_uid : uid
      redirect_to smart_success_path, :notice => "Signed in!"
    end
  end

end
