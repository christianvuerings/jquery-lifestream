class ActAsController < ApplicationController

  include ClassLogger

  skip_before_filter :check_reauthentication, :only => [:stop_act_as]

  def start
    return redirect_to root_path unless valid_params?(current_user, params[:uid])
    logger.warn "ACT-AS: User #{session[:user_id]} acting as #{params[:uid]} begin"
    session[:original_user_id] = session[:user_id] unless session[:original_user_id]
    session[:user_id] = params[:uid]

    render :nothing => true, :status => 204
  end

  def stop
    return redirect_to root_path unless session[:user_id] && session[:original_user_id]

    #To avoid any potential stale data issues, we might have to be aggressive with cache invalidation.
    pseudo_user = Calcentral::PSEUDO_USER_PREFIX + session[:user_id]
    [pseudo_user, session[:user_id]].each do |cache_key|
      Cache::UserCacheExpiry.notify cache_key
    end
    logger.warn "ACT-AS: User #{session[:original_user_id]} acting as #{session[:user_id]} ends"
    session[:user_id] = session[:original_user_id]
    session[:original_user_id] = nil

    render :nothing => true, :status => 204
  end

  private

  def valid_params?(current_user, act_as_uid)
    if current_user.blank? || act_as_uid.blank?
      logger.warn "ACT-AS: User #{current_user.uid} FAILED to login to #{act_as_uid}, either cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      [current_user.uid, act_as_uid].each do |param|
        Integer(param, 10)
      end
    rescue ArgumentError
      logger.warn "ACT-AS: User #{current_user.uid} FAILED to login to #{act_as_uid}, values must be integers"
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
