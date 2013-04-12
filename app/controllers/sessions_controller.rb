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
      Calcentral::USER_CACHE_EXPIRATION.notify session[:user_id]
      reset_session
    ensure
      Rails.logger.debug "Clearing connections for thread and other dead threads due to user logout: #{self.object_id}"
      ActiveRecord::Base.clear_active_connections!
    end
    render :json => {
      :redirect_url => "#{Settings.cas_logout_url}?url=#{CGI.escape(request.protocol + request.host_with_port)}"
    }.to_json
  end

  def new
    redirect_to '/auth/cas'
  end

  def failure
    params ||= {}
    params[:message] ||= ''
    redirect_to root_url, :status => 401, :alert => "Authentication error: #{params[:message].humanize}"
  end

  private

  def continue_login_success(uid)
    session[:user_id] = uid
    Calcentral::USER_CACHE_WARMER.warm session[:user_id]
    redirect_to '/dashboard', :notice => "Signed in!"
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
    if never_logged_in_before
      Rails.logger.warn "ACT-AS: User #{user_uid} FAILS to login to #{act_as_uid}, #{act_as_uid} hasn't logged in before."
      return false
    end

    if !UserAuth.is_superuser?(session[:user_id])
      Rails.logger.warn "ACT-AS: User #{user_uid} FAILS to login to #{act_as_uid}, #{user_uid} isn't a superuser."
      return false
    end

    return true
  end

end
