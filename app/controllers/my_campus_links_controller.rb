class MyCampusLinksController < ApplicationController

  def get_feed
    if session[:user_id]
      # nil user ID makes the MyCampusLinks cache on a global level
      render :json => MyCampusLinks.new(nil, nil).get_feed.to_json
    else
      render :json => {}.to_json
    end
  end

  def expire
    # Only super-users are allowed to clear this cache
    unless UserAuth.is_superuser?(session[:user_id])
      return render :nothing => true, :status => 401
    end
    Rails.logger.info "Expiring MyCampusLinks cache"
    MyCampusLinks.expire nil
    render :nothing => true, :status => 204
  end

end
