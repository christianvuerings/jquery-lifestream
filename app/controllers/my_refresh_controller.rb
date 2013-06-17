class MyRefreshController < ApplicationController
  extend Calcentral::Cacheable

  def self.expire(id = nil)
    # no-op; this class uses the cache only to rate-limit. We want to just expire
    # with time, not when the cache is forcibly cleared.
  end

  def refresh
    if session[:user_id]
      self.class.fetch_from_cache session[:user_id] do
        sleep 2
        Calcentral::USER_CACHE_EXPIRATION.notify session[:user_id]
        UserCacheWarmer.do_warm session[:user_id]
        true
      end
      render :nothing => true, :status => 204
    else
      render :nothing => true, :status => 401
    end
  end

end
