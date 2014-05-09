class ClearCacheController < ApplicationController

  include ClassLogger

  def do
    authorize(current_user, :can_clear_cache?)
    logger.info "Clearing all cache entries"
    Rails.cache.clear
    render :nothing => true, :status => 204
  end

end
