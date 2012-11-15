class UserApiController < ApplicationController

  caches_action(:status)

  def status
    user = get_user(session[:user_id])
    if session[:user_id]
      render :json => {
          :is_logged_in => true,
          :preferred_name => user.preferred_name || "",
          :uid => session[:user_id],
          :widget_data => {}
      }.to_json
    else
      render :json => {
          :is_logged_in => false
      }.to_json
    end
  end

  def get_user(uid)
    Rails.cache.fetch(cache_key(uid)) do
      UserApi.new(uid)
    end
  end

  def cache_key(uid)
    "user_#{uid}"
  end

  # TODO expire is not yet used, but should be called from any code that saves a user
  def expire(uid)
    expire_action(:controller => 'user_api', :action => 'status', :uid => uid)
    Rails.cache.delete(cache_key(uid), :force => true)
  end

end
