class CacheController < ApplicationController

  include ClassLogger

  before_filter :check_permission

  def clear
    logger.warn 'Clearing all cache entries'
    Rails.cache.clear
    render :json => {cache_cleared: true}
  end

  def warm
    uid = params['uid'].to_i
    if uid && uid > 0
      logger.warn "Will warm cache for user #{uid}"
      HotPlate.request_warmup uid
    else
      logger.warn 'Will warm cache for all users'
      HotPlate.request_warmups_for_all
    end
    render :json => {warmed: true}
  end

  private

  def check_permission
    authorize(current_user, :can_clear_cache?)
  end
end
