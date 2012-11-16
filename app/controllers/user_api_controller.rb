class UserApiController < ApplicationController

  caches_action :status, :cache_path => proc {
    if session[:user_id]
      "#{mystatus_url}?uid=#{session[:user_id]}"
    else
      "#{mystatus_url}?uid=anonymous"
    end
  }

  caches_action :userstatus

  def mystatus
    if session[:user_id]
      user_data = get_user_data session[:user_id]
      render :json => {
          :is_logged_in => true
      }.merge!(user_data).to_json
    else
      render :json => {
          :is_logged_in => false
      }.to_json
    end
  end

  def userstatus
    # TODO add check to see if remote user has permission to read this uid
    user_data = get_user_data params[:uid]
    render :json => user_data.to_json
  end

  def get_user_data(uid)
    Rails.cache.fetch(cache_key(uid)) do
      user = UserApi.new(uid)
      {
          :uid => user.uid,
          :preferred_name => user.preferred_name || "",
          :widget_data => {}
      }
    end
  end

  def cache_key(uid)
    "user_#{uid}"
  end

  # TODO expire is not yet used, but should be called from any code that saves a user
  def expire(uid)
    expire_action(:controller => 'user_api', :action => 'userstatus', :uid => uid)
    expire_action(:controller => 'user_api', :action => 'mystatus')
    Rails.cache.delete(cache_key(uid), :force => true)
  end

end
