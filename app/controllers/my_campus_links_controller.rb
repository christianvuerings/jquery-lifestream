class MyCampusLinksController < ApplicationController

  extend Calcentral::Cacheable

  def get_feed
    if session[:user_id]
      json = self.class.fetch_from_cache {
        MyCampusLinks.new.get_feed.to_json
      }
      render :json => json
    else
      render :json => {}.to_json
    end
  end

  def expire
    # Only super-users are allowed to clear this cache
    unless UserAuth.is_superuser?(session[:user_id])
      return render :nothing => true, :status => 401
    end
    Rails.logger.info "Expiring MyCampusLinksController cache"
    self.class.expire
    get_feed
  end

end
