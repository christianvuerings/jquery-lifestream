class MyRefreshController < ApplicationController
  extend Calcentral::Cacheable

  respond_to :json

  def self.expire(id = nil)
    # no-op; this class uses the cache only to rate-limit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def refresh
    if session[:user_id]
      if Rails.env.development?
        render :json => {:refreshed => Time.now.to_i}, :status => 200
      elsif self.class.in_cache? session[:user_id]
        render :json => {:refreshed => Time.now.to_i}, :status => 304
      else
        self.class.fetch_from_cache session[:user_id] do
          sleep 2
          Calcentral::USER_CACHE_EXPIRATION.notify session[:user_id]
          UserCacheWarmer.do_warm session[:user_id]
          true
        end
        render :json => {:refreshed => Time.now.to_i}, :status => 200
      end
    else
      render :nothing => true, :status => 401
    end
  end

end
