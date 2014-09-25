class ActAsController < ApplicationController

  include ClassLogger

  skip_before_filter :check_reauthentication, :only => [:stop_act_as]

  def start
    authorize current_user, :can_view_as?
    return redirect_to root_path unless valid_params?(params[:uid])
    logger.warn "ACT-AS: User #{current_user.real_user_id} acting as #{params[:uid]} begin"
    session[:original_user_id] = session[:user_id] unless session[:original_user_id]
    session[:user_id] = params[:uid]

    render :nothing => true, :status => 204
  end

  def stop
    return redirect_to root_path unless session[:user_id] && session[:original_user_id]

    #To avoid any potential stale data issues, we might have to be aggressive with cache invalidation.
    Cache::UserCacheExpiry.notify session[:user_id]
    logger.warn "ACT-AS: User #{session[:original_user_id]} acting as #{session[:user_id]} ends"
    session[:user_id] = session[:original_user_id]
    session[:original_user_id] = nil

    render :nothing => true, :status => 204
  end

  private

  def valid_params?(act_as_uid)
    if act_as_uid.blank?
      logger.warn "ACT-AS: User #{current_user.real_user_id} FAILED to login to #{act_as_uid}, cannot be blank!"
      return false
    end

    # Ensure that uids are numeric
    begin
      Integer(act_as_uid, 10)
    rescue ArgumentError
      logger.warn "ACT-AS: User #{current_user.user_id} FAILED to login to #{act_as_uid}, values must be integers"
      return false
    end

    # Ensure uid is in our database
    if CampusOracle::Queries.find_people_by_uid(act_as_uid).blank?
      logger.warn "ACT-AS: User #{current_user.real_user_id} FAILED to login to #{act_as_uid}, act_as_uid not found"
      return false
    end
    true
  end

end
