class UserApiController < ApplicationController

  caches_action :mystatus, :cache_path => proc {
    if session[:user_id]
      "user/#{session[:user_id]}/api/my/status"
    else
      "user/anonymous/api/my/status"
    end
  }

  def mystatus
    logger.debug "mystatus for uid '#{session[:user_id]}'"
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

  def self.expire(uid)
    key = "views/user/#{uid}/api/my/status.json"
    Rails.logger.debug "UserApiController expiring cache key = #{key}"
    Rails.cache.delete(key, :force => true)
  end

end
