class MyCampusLinksController < ApplicationController

  extend Cache::Cacheable

  def get_feed
    if session[:user_id]
      json = self.class.fetch_from_cache {
        Links::MyCampusLinks.new.get_feed.to_json
      }
      render :json => json
    else
      render :json => {}.to_json
    end
  end

  def expire
    authorize(current_user, :can_clear_campus_links_cache?)
    Rails.logger.info "Expiring MyCampusLinksController cache"
    self.class.expire
    get_feed
  end

end
