class MyCampusLinksController < ApplicationController

  extend Cache::Cacheable
  before_filter :api_authenticate

  def get_feed
    json = self.class.fetch_from_cache {
      Links::MyCampusLinks.new.get_feed.to_json
    }
    render :json => json
  end

  def expire
    authorize(current_user, :can_clear_campus_links_cache?)
    Rails.logger.info "Expiring MyCampusLinksController cache"
    self.class.expire
    get_feed
  end

end
