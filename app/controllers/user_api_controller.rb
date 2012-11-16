class UserApiController < ApplicationController

  caches_action :status, :cache_path => proc {
    if session[:user_id]
      "#{mystatus_url}?uid=#{session[:user_id]}"
    else
      "#{mystatus_url}?uid=anonymous"
    end
  }

  def mystatus
    if session[:user_id]
      user_data = UserApi.get_user_data session[:user_id]
      render :json => {
          :is_logged_in => true
      }.merge!(user_data).to_json
    else
      render :json => {
          :is_logged_in => false
      }.to_json
    end
  end

  # TODO expire is not yet used, but should be called from any code that saves a user
  def expire(uid)
    expire_action(:controller => 'user_api', :action => 'mystatus')
  end

end
